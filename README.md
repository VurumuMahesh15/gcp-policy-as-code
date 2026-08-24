# Policy-as-Code Enforcement & Observability Platform

A GCP-native platform that enforces infrastructure policy automatically — catching non-compliant Terraform changes before they're applied, and giving visibility into infrastructure state and policy violations through a live observability layer.

Built by **Vurumu Mahesh (VM)** — Platform Engineering / SRE portfolio project.

---

## What this does

Every infrastructure change goes through automated policy checks before it's allowed to touch real GCP resources. On top of that, the platform observes what's actually running, so drift and violations are visible in real time, not just caught at commit time.

```
Terraform code pushed
        ↓
CI validates + applies (multi-environment: dev/staging/prod)
        ↓
OPA/Rego policies (via Conftest) check the plan for violations
        ↓
tfsec scans for security misconfigurations
        ↓
If compliant → infrastructure is provisioned on GCP
        ↓
Cloud Monitoring + Cloud Logging + Grafana observe it continuously
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
| **CI/CD** | GitHub Actions | Automates validate → policy check → apply, across environments |
| **Container orchestration** | Kubernetes (GKE) | Runs policy checks in isolated, reproducible Jobs |
| **Observability** | Cloud Monitoring, Cloud Logging, Grafana | Tracks infrastructure state, policy violations, and drift |
| **Cloud provider** | Google Cloud Platform | Where the actual infrastructure lives |

---

## Environments

This platform is built and run primarily in **`dev`** — real Terraform, real policies, real Grafana dashboard, real Cloud Monitoring, all live against actual GCP resources. Keeping this to one live environment avoids running 3x the infrastructure (and 3x the cost) for a portfolio-scale project.

The Terraform config is still **environment-aware** (`environment` variable, e.g. `dev`/`staging`/`prod`) so the same code could be pointed at additional environments later without a rewrite — but only `dev` runs live infrastructure for now.

The full multi-environment CI/CD *pipeline pattern* (staged approvals, wait timers, matrix builds across dev/staging/prod) is separately proven out in the companion repo: [GithubProjects-VM-](https://github.com/VurumuMahesh15/GithubProjects-VM-).

---

## Project status

🚧 **In active development** — build started August 21, 2026.

**Completed so far:**
- [x] GCP project provisioned (`policy-as-code-platform`)
- [x] Required APIs enabled (Compute, GKE, Monitoring, Logging, IAM, Resource Manager)
- [x] Terraform service account created with scoped IAM role
- [x] Budget alert configured on free trial credit
- [x] Core CI/CD mechanism proven — Kubernetes Job running Conftest/OPA policy checks against real Terraform inside a disposable cluster spun up in GitHub Actions

**In progress / planned:**
- [x] Real GCP infrastructure defined in Terraform
- [ ] Meaningful Rego policy set (beyond initial proof-of-concept policies)
- [ ] tfsec integrated into the pipeline
- [ ] Cloud Monitoring + Cloud Logging wired up
- [ ] Grafana dashboard deployed and connected
- [ ] (Later phase, ~1 month out) RAG-based natural-language interface over policy violations and logs, using Ollama + local embeddings

**Recent progress:** Kubernetes Job pipeline with Conftest/OPA policy checks against real Terraform is proven in GitHub Actions (August 2026).

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