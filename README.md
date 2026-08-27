# Policy-as-Code Enforcement & Observability Platform

A GCP-native platform that enforces infrastructure policy automatically — catching non-compliant Terraform changes before they're applied, and giving visibility into infrastructure state and policy violations through a live observability layer.

Built by **Vurumu Mahesh (VM)** — Platform Engineering / SRE portfolio project.

---

## What this does

Infrastructure changes can be checked against versioned policy before they touch real GCP resources. A planned observability layer will track what's running, so drift and violations can be visible in real time rather than only at commit time.

```
Terraform code pushed
        ↓
CI validates + applies (companion pipeline; dev scope here)
        ↓
OPA/Rego policies (via Conftest) check the plan for violations
        ↓
tfsec scans for security misconfigurations (planned)
        ↓
If compliant → infrastructure is provisioned on GCP
        ↓
Cloud Monitoring + Cloud Logging + Grafana observe it continuously (planned)
```

---

## Why this exists

Most Terraform pipelines validate syntax (`terraform validate`) but don't enforce *organizational rules* — things like "no public storage buckets," "only approved instance types," "every resource must have an owner tag." This platform closes that gap: policy is written as code, versioned, tested, and enforced automatically, not left to manual review or tribal knowledge.

---

## Tech stack

| Layer | Tool | Purpose |
|---|---|---|
| **Infrastructure as Code** | Terraform | Defines and provisions GCP resources |
| **Policy engine** | OPA (Open Policy Agent) + Rego | Encodes the actual compliance rules |
| **Policy test runner** | Conftest | Runs Rego policies against Terraform plan output |
| **Security scanning** | tfsec | Catches security misconfigurations in Terraform code |
| **CI/CD** | GitHub Actions (companion repo) | Automates validate → policy check → apply |
| **Container orchestration** | Kubernetes (GKE) | Runs policy checks in isolated, reproducible Jobs |
| **Observability** | Cloud Monitoring, Cloud Logging, Grafana | Tracks infrastructure state, policy violations, and drift |
| **Cloud provider** | Google Cloud Platform | Where the actual infrastructure lives |

---

## Getting started

The Terraform configuration currently targets the `policy-as-code-platform` GCP project and is intended to be run from the `terraform/` directory.

Before running Terraform:

1. Provide Google Cloud credentials in `terraform/terraform-key.json`. This file is ignored by Git and must never be committed.
2. Set `master_authorized_cidr` to a trusted administrator CIDR. This controls access to the public GKE control-plane endpoint; do not use `0.0.0.0/0`.

```bash
cd terraform
# Replace the example CIDR with your trusted administrator IP/CIDR.
export TF_VAR_master_authorized_cidr="203.0.113.10/32"
terraform init
terraform plan
terraform apply
```

The cluster uses private nodes and a public control-plane endpoint restricted by the authorized CIDR. Review the plan carefully before applying it to GCP.

---

## Environments

This platform is built and run primarily in **`dev`** — real Terraform and policy checks are maintained against the `policy-as-code-platform` project. Cloud Monitoring, Cloud Logging, and Grafana integrations are still being wired up. Keeping this to one live environment avoids running 3x the infrastructure (and 3x the cost) for a portfolio-scale project.

The current Terraform labels target `dev` directly. Supporting additional environments (`staging`/`prod`) without duplicating configuration remains future work.

The full multi-environment CI/CD *pipeline pattern* (staged approvals, wait timers, matrix builds across dev/staging/prod) is separately proven out in the companion repo: [GithubProjects-VM-](https://github.com/VurumuMahesh15/GithubProjects-VM-). This repository does not currently contain a `.github/workflows` directory.

---

## Project status

🚧 **In active development** — build started August 21, 2026.

**Completed so far:**
- [x] GCP project provisioned (`policy-as-code-platform`)
- [x] Required APIs enabled (Compute, GKE, Monitoring, Logging, IAM, Resource Manager)
- [x] Terraform service account created with scoped IAM role
- [x] Budget alert configured on free trial credit
- [x] Core CI/CD mechanism proven in the companion GitHub Actions pipeline — Kubernetes Job running Conftest/OPA policy checks against real Terraform inside a disposable cluster
- [x] Baseline GKE hardening defined in Terraform (private nodes, network policy, authorized control-plane CIDR, and dedicated node service account)
- [x] GKE security policy rules defined in Rego for private nodes, network policy, authorized networks, node image, metadata mode, upgrades, and service accounts
- [x] Real GCP infrastructure defined in Terraform

**In progress / planned:**
- [ ] Apply and verify the hardened GKE configuration and IAM bindings in the `dev` project
- [ ] Add isolated test fixtures and CI coverage for the GKE security policy rules
- [ ] Expand the Rego policy set beyond the initial proof-of-concept policies
- [ ] Regenerate the Terraform plan after configuration changes and run the complete policy gate against it
- [ ] tfsec integrated into the pipeline
- [ ] Cloud Monitoring + Cloud Logging wired up
- [ ] Grafana dashboard deployed and connected
- [ ] (Later phase, ~1 month out) RAG-based natural-language interface over policy violations and logs, using Ollama + local embeddings

**Recent progress:** Kubernetes Job pipeline with Conftest/OPA policy checks against real Terraform is proven in the companion GitHub Actions pipeline (August 2026).

---

## Architecture decisions

- **GitHub Actions over Cloud Build** — keeps CI/CD in one familiar, portable system
- **tfsec over Checkov** — chosen for this project's security scanning
- **GCP-native Cloud Monitoring as Grafana's data source** — over self-hosting Prometheus, reducing operational overhead
- **Kubernetes Jobs for policy checks** — proves the enforcement mechanism works as a real cluster workload, not just a CI script, closer to how this would run in production

---

## Related project

This platform's CI/CD and policy-enforcement mechanics were first prototyped and debugged in a standalone practice repo: [GithubProjects-VM-](https://github.com/VurumuMahesh15/GithubProjects-VM-), under `ci-cd-k8s-policy-pipeline/`.

---

## Contact

**Vurumu Mahesh (VM)**
📧 [vgsvpmahesh@gmail.com](mailto:vgsvpmahesh@gmail.com)
🔗 [GitHub](https://github.com/VurumuMahesh15) · [LinkedIn](https://www.linkedin.com/in/vurumu-mahesh-ba572a293/)
