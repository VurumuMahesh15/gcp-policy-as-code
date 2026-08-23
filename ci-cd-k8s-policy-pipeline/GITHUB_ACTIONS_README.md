# Multi-Environment Deployment Report Pipeline

![Pipeline Status](https://github.com/VurumuMahesh15/GithubProjects-VM-/actions/workflows/pipeline.yaml/badge.svg)

## Folder structure

```
GithubProjects-VM-/
├── .github/
│   ├── actions/
│   │   └── generate-report/
│   │       └── action.yaml
│   └── workflows/
│       └── pipeline.yaml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       └── deployment_record/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
└── GITHUB_ACTIONS_README.md
```

## What it does

On every push/PR to `main` (or manual trigger), the pipeline:
1. Generates a unique version string (timestamp + commit SHA)
2. Runs a matrix job across three environments — `dev`, `staging`, `prod` —
   each producing a deployment report via a shared composite action
3. Runs a Terraform matrix job in a `hashicorp/terraform` container that
   formats, initializes, validates, and applies the infra for each
   environment, then captures the outputs
4. Combines all environment and Terraform reports into a single
   versioned artifact

## Key concepts demonstrated

- **GitHub Environments** — `prod` requires manual approval before running;
  `staging` has a wait timer; `dev` runs immediately. Configured via
  Settings → Environments, referenced in the workflow via `environment:`.
- **Composite actions** — report-generation logic is written once
  (`.github/actions/generate-report/action.yaml`) and reused across all three
  environment legs, avoiding duplication.
- **Matrix builds** — one job definition fans out into three parallel
  runs, one per environment (for both the report and Terraform jobs).
- **Job outputs / cross-job data passing** — the version string is
  generated once and shared across all downstream jobs via `needs`.
- **Containerized jobs** — the `terraform_check` job runs inside the
  `hashicorp/terraform:1.7` container for toolchain consistency.
- **Artifacts** — each environment's report and Terraform output are
  uploaded individually, then downloaded and merged into one final report.
- **Job summaries** — each job writes a markdown summary to `$GITHUB_STEP_SUMMARY`
  that shows up on the run's summary page.
- **Concurrency control** — overlapping runs on the same branch cancel
  the older one automatically.
- **Least-privilege permissions** — `GITHUB_TOKEN` is scoped to
  read-only, since no write access is needed.

## Pipeline flow

```
push/PR/manual trigger
        │
        ▼
   version job (generates version string)
        │
        ├───────────────┬──────────────────┐
        ▼               ▼                  ▼
 report job × 3    terraform_check × 3
 (dev/staging/prod) (fmt → init → validate
  generates report)  → apply → output)
        │               │
        └───────┬───────┘
                ▼
        combine job (merges report-* and
        tf-output-* artifacts into one)
```

## Setup notes

- Requires three GitHub Environments configured under
  Settings → Environments: `dev`, `staging`, `prod`, with `prod` set to
  require a reviewer.
- The Terraform root module only writes a `deployment-record-<env>.txt`
  local file via the `deployment_record` module, so no cloud credentials
  are needed.

## Possible extensions

- Add OPA/Rego + Conftest policy checks against the Terraform plan
- Run `report` jobs inside a Docker container for environment consistency
- Add OIDC-based cloud authentication instead of static secrets
- Add `tfsec` scanning as a separate job
