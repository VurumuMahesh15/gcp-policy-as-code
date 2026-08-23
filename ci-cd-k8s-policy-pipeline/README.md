# CI/CD Kubernetes Policy Pipeline

A production-grade GitHub Actions CI/CD pipeline demonstrating **Policy-as-Code** enforcement for Terraform infrastructure on Kubernetes using OPA/Rego with Conftest, running in ephemeral Kind clusters.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GITHUB ACTIONS WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐          │
│  │ version  │───▶│  report  │───▶│ terraform_chk│───▶│ combine  │          │
│  └──────────┘    └──────────┘    └──────┬───────┘    └──────────┘          │
│                                          │                                    │
│                                          ▼                                    │
│                                 ┌─────────────────┐                          │
│                                 │ k8s-policy-chck │                          │
│                                 │  (parallel)     │                          │
│                                 └────────┬────────┘                          │
│                                          │                                    │
│                    ┌─────────────────────┼─────────────────────┐              │
│                    ▼                     ▼                     ▼              │
│            ┌───────────┐         ┌───────────┐         ┌───────────┐         │
│            │  Kind     │         │  Apply    │         │  Wait &   │         │
│            │  Cluster  │────────▶│  Job      │────────▶│  Debug    │         │
│            └───────────┘         └───────────┘         └───────────┘         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Pipeline Stages

| Job | Purpose | Matrix | Environment |
|-----|---------|--------|-------------|
| `version` | Generates build timestamp + SHA | — | — |
| `report` | Generates deployment reports | `dev`, `staging`, `prod` | GitHub Environments |
| `terraform_check` | Validates & applies Terraform | `dev`, `staging`, `prod` | GitHub Environments |
| `combine` | Aggregates all artifacts | — | — |
| `k8s-policy-check` | Policy validation in Kind | — | — |

## Policy Enforcement (`policy-enforcement/`)

```
policy-enforcement/
├── kind-config.yaml      # Kind cluster with hostPath mount to repo
├── job.yaml              # K8s Job running Conftest
└── policies/
    └── terraform.rego    # OPA/Rego policies for Terraform
```

### Conftest Policy Checks

The `terraform.rego` policy validates:
- **Required tags** on all resources (Environment, Owner, Project)
- **No public IP exposure** on compute instances
- **Encryption at rest** for storage resources
- **Least-privilege IAM** bindings

```bash
# Local testing
conftest test ci-cd-k8s-policy-pipeline/terraform/*.tf \
  --policy ci-cd-k8s-policy-pipeline/policy-enforcement/policies
```

### Kind Cluster Configuration

The Kind cluster mounts the entire repository at `/workspace` inside the container, making both Terraform configs and policies available to the job:

```yaml
extraMounts:
  - hostPath: /home/runner/work/GithubProjects-VM-/GithubProjects-VM-
    containerPath: /workspace
```

## Terraform Infrastructure (`terraform/`)

```
terraform/
├── main.tf                      # Root module
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── modules/
│   └── deployment_record/       # Reusable deployment tracking module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .terraform.lock.hcl          # Provider lock file
```

**Resources provisioned per environment:**
- Google Cloud Storage bucket (with versioning & encryption)
- Cloud Monitoring workspace
- Service accounts with least-privilege roles
- Deployment record tracking via custom module

## Local Development

### Prerequisites
- Terraform ≥ 1.7
- Docker (for Kind)
- `kubectl` ≥ 1.28
- `conftest` ≥ 0.48
- `devbox` (optional, for reproducible env)

### Quick Start

```bash
# 1. Enter dev environment
devbox shell

# 2. Format & validate Terraform
task tf:fmt
task tf:validate

# 3. Create local Kind cluster
task kind:create

# 4. Run policy checks locally
kubectl apply -f ci-cd-k8s-policy-pipeline/policy-enforcement/job.yaml
kubectl wait --for=condition=complete job/tf-check -n dev --timeout=60s
kubectl logs job/tf-check -n dev

# 5. Cleanup
task kind:delete
```

### Available Tasks

```bash
task --list-all
# tf:fmt        Format all Terraform files
# tf:init       Initialize working directory
# tf:validate   Validate configuration
# tf:plan       Generate plan (set environment=staging)
# tf:apply      Apply configuration
# tf:output     Show outputs as JSON
# kind:create   Create local Kind cluster
# kind:delete   Delete local Kind cluster
```

## CI/CD Workflow Details

### Trigger Conditions
- Push to `main`
- Pull requests targeting `main`
- Manual dispatch (`workflow_dispatch`)

### Concurrency Control
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Artifacts Produced
| Artifact | Source Job | Retention |
|----------|------------|-----------|
| `report-{env}` | `report` | 90 days |
| `tf-output-{env}` | `terraform_check` | 90 days |
| `deployment-report-{version}` | `combine` | 90 days |

### Environment Protection
Each environment (`dev`, `staging`, `prod`) requires manual approval before `terraform_check` applies changes.

## Security Considerations

- **No secrets in repo** — GCP credentials via GitHub Environments + OIDC
- **Provider lock file** committed (`.terraform.lock.hcl`)
- **Policy-as-Code** prevents misconfigurations at CI time
- **Ephemeral clusters** — Kind clusters destroyed after each run
- **Least-privilege IAM** enforced via Rego policies

## Project Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── pipeline.yaml          # Main CI/CD workflow
│   └── actions/
│       └── generate-report/       # Composite action for reports
├── ci-cd-k8s-policy-pipeline/
│   ├── terraform/                 # Infrastructure as Code
│   ├── policy-enforcement/        # OPA/Rego + Conftest + Kind
│   ├── Taskfile.yaml              # Task runner scripts
│   ├── devbox.json                # Dev environment definition
│   ├── devbox.lock                # Locked dev dependencies
│   ├── README.md                  # This file
│   └── GITHUB_ACTIONS_README.md   # Workflow deep-dive
├── k8s-practice/                  # K8s learning exercises (gitignored)
├── opa_practice/                  # OPA/Rego learning exercises (gitignored)
├── .gitignore
└── .devbox/                       # Devbox internals (gitignored)
```

## Extending Policies

Add new `.rego` files to `policy-enforcement/policies/` — Conftest evaluates all automatically:

```bash
policy-enforcement/policies/
├── terraform.rego      # Core infrastructure policies
├── security.rego       # Security-specific rules
├── cost.rego           # Cost optimization rules
└── naming.rego         # Naming convention enforcement
```

## Debugging Failed Policy Checks

The workflow includes automated debug output on failure:

```yaml
- name: Debug - show pod status if failed
  if: failure()
  run: |
    kubectl get pods -n dev
    kubectl describe pod -n dev -l job-name=tf-check
    kubectl logs -n dev -l job-name=tf-check --all-containers=true || true
```

## References

- [OPA/Rego Language](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Conftest Documentation](https://www.conftest.dev/)
- [Kind Configuration](https://kind.sigs.k8s.io/docs/user/configuration/)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

**Author:** Vurumu Mahesh (VM39) — Platform Engineering / SRE aspirant (2026 batch)  
**Contact:** vgsvpmahesh@gmail.com