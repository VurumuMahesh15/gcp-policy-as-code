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
python3 -m json.tool grafana/provisioning/datasources/cloud-monitoring.yaml > /dev/null 2>&1 || python3 -c "import yaml,sys" 2>/dev/null || echo "(YAML needs a parser with PyYAML; visual check suffices)"
```

## Connect (when the lab is live)

```bash
cp grafana/variables.env.example grafana/variables.env
export GCP_PROJECT=policy-as-code-platform
# run Grafana (local container or GCP-hosted) with ADC/SA auth,
# mount ./grafana/provisioning to /etc/grafana/provisioning
# and ./grafana/dashboards to /var/lib/grafana/dashboards
```
