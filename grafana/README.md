# Grafana (as configuration, not a running server)

> **Grafana is provisioned as configuration rather than continuously deployed
> infrastructure.** The project keeps GKE destroyed when not in use to avoid
> unnecessary GCP costs, so there is intentionally no live Grafana to screenshot.
> The datasource and dashboard below are reproducible and connect as soon as the
> incident lab is brought online. An empty dashboard while the lab is destroyed
> is honest — no fake metrics are generated to populate it.

## Layout

```text
                 GCP
                  │
        ┌─────────┴─────────┐
        │ Cloud Monitoring  │
        │ Cloud Logging     │
        └─────────┬─────────┘
                  │
          Grafana datasource
          (Cloud Monitoring)
                  │
        ┌─────────┴─────────┐
        │  SRE Dashboard    │
        ├───────────────────┤
        │ 1. Health         │
        │ 2. Degradation    │
        │ 3. Incident       │
        └───────────────────┘
```

## Files

| File | Purpose |
|------|---------|
| `provisioning/datasources/cloud-monitoring.yaml` | Cloud Monitoring (Stackdriver) datasource; project via `$GCP_PROJECT`, auth via runtime SA/ADC — no stored credentials |
| `provisioning/dashboards/sre.yaml` | File-based dashboard provider (`SRE` folder) |
| `dashboards/sre-dashboard.json` | The dashboard: Health / Degradation / Incident rows |
| `variables.env.example` | Copy to `variables.env` (gitignored) when running Grafana locally |

## Dashboard sections → SRE questions

1. **Health** — node CPU (same signal + 0.8 threshold as the Terraform alert),
   container CPU, node memory, and the alert contract (a pointer, not a faked status).
2. **Degradation** — wide-window CPU to separate spikes from trends, plus the
   exact Cloud Logging query to correlate errors in the same window.
3. **Incident** — the step-by-step CPU walkthrough used in chaos drills
   (spike → alert → identify → logs → mitigate → recover → verify),
   linking `docs/runbooks/high-cpu.md` and `docs/chaos-test-01-high-cpu.md`.

Metric types match `terraform/observability.tf` and `terraform/dashboard.tf`
(`k8s_node` allocatable utilization, `k8s_container` CPU); the 0.8 threshold
matches `google_monitoring_alert_policy.high_cpu`.

## Validate

```bash
python3 -m json.tool grafana/dashboards/sre-dashboard.json > /dev/null && echo "dashboard JSON valid"
# YAML files are simple provisioning docs; review by eye or with `yamllint` if installed.
```

## Run Grafana locally (Bring Your Own GCP project)

The dashboard is credential-free config: it queries **your** GCP project, not the
author's. Nobody cloning this repo needs your keys, and you don't need theirs.

```text
Clone repo
   ↓
Create/select YOUR GCP project, enable Cloud Monitoring
   ↓
Give Grafana read-only access to that project (see Auth below)
   ↓
Set GCP_PROJECT to your project ID
   ↓
Start Grafana with the included provisioning
   ↓
Dashboard loads automatically, querying YOUR metrics
```

1. **GCP project** — create or pick a project and enable the Cloud Monitoring API.
   You need a running GKE workload emitting Kubernetes metrics, otherwise panels
   show no data (see "No data ≠ broken" below).
2. **Auth (read-only, preferred order):**
   - **Application Default Credentials (preferred for local use):**
     `gcloud auth application-default login`, then mount your ADC config into
     the container read-only (see the `docker run` below). No keys to manage.
   - **Service-account key (fallback):** create a key for a principal with only
     `roles/monitoring.viewer` on your project, mount it read-only, and point
     `GOOGLE_APPLICATION_CREDENTIALS` at it. **Never commit the key file —
     it is gitignored (`*-credentials.json`, `service-account*.json`).**
3. **Project + cluster:**
   ```bash
   cp grafana/variables.env.example grafana/variables.env
   # edit grafana/variables.env:
   #   GCP_PROJECT=<your-project-id>
   export GCP_PROJECT=<your-project-id>
   ```
   If your GKE cluster name differs, change the `cluster` variable at the top
   of the dashboard (it's a textbox, no JSON editing needed).
4. **Start Grafana:**
   ```bash
   docker run -d --name grafana \
     -p 3000:3000 \
     -e GCP_PROJECT="$GCP_PROJECT" \
     -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
     -v "$PWD/grafana/provisioning:/etc/grafana/provisioning:ro" \
     -v "$PWD/grafana/dashboards:/var/lib/grafana/dashboards:ro" \
     grafana/grafana
   ```
   Open `http://localhost:3000` — the SRE dashboard is pre-provisioned under
   the `SRE` folder.

## No data ≠ broken

```text
Dashboard ≠ data
```

The dashboard is only the visualization/query definition. Data flows:

```text
GKE / Kubernetes
       ↓
Cloud Monitoring
       ↓
Grafana
       ↓
Dashboard
```

If the cluster is destroyed or no matching metrics exist yet in your project,
panels legitimately show **No data**. That means the pipeline has nothing to
read — not that the dashboard is broken. Bring a workload online, generate
some CPU load, and the panels will populate.

## Known query caveat

The node-CPU panels (`kubernetes.io/node/cpu/allocatable_utilization`) carry
**no `resource.cluster_name` filter**: Cloud Monitoring rejects that filter on
this metric, so those panels scope by the datasource's GCP project instead —
the same scoping as `terraform/observability.tf` and `terraform/dashboard.tf`.
If you hit a similar rejection on another panel, drop its cluster filter the
same way rather than working around it with a key or a hardcoded project.
