# Chaos Test Report: High CPU Incident

**Date:** 2026-09-17
**Scenario:** CPU stress on GKE node
**Duration:** ~30 minutes
**Result:** ✅ PASS - Alert fired, dashboard showed live data, recovery verified

---

## Summary

Intentionally saturated a GKE e2-small node with CPU stress workloads to verify:
1. Cloud Monitoring alert fires correctly
2. SRE dashboard displays live metrics
3. System recovers after workload removal

**Key Finding:** Original alert used wrong metric (`gce_instance` vs `k8s_node`). Fixed during test.

---

## Timeline

| Time | Event | Node CPU |
|------|-------|----------|
| T+0 | Deployed 1x cpu-stress pod (500m limit) | 85% |
| T+5 | Alert did NOT fire (wrong metric) | 84% |
| T+10 | Fixed alert to use `k8s_node` metric | 65% |
| T+12 | Scaled to 2x replicas | 68% |
| T+15 | Node saturated | 86% |
| T+20 | **Alert FIRED** ✅ | 87% |
| T+22 | Dashboard showing live graph ✅ | 85% |
| T+25 | Deleted workload | 86% |
| T+27 | **Recovery verified** ✅ | 30% |

---

## Bug Found & Fixed

**Problem:** Alert policy monitored `compute.googleapis.com/instance/cpu/utilization` with `resource.type="gce_instance"`, but GKE nodes report as `k8s_node` resource type.

**Fix:** Changed to `kubernetes.io/node/cpu/allocatable_utilization` with `resource.type="k8s_node"`.

**Files changed:**
- `terraform/observability.tf` - Alert filter updated
- `terraform/dashboard.tf` - Widget updated to match

---

## Verification

- [x] Alert policy enabled and configured
- [x] Stress workload deployed successfully
- [x] Node CPU exceeded 80% threshold
- [x] Alert incident opened in Cloud Console
- [x] Dashboard displayed live CPU graph
- [x] Workload removal caused CPU recovery (86% → 30%)
- [x] Alert auto-resolved after recovery

---

## Lessons Learned

1. GKE nodes use different metric namespace than GCE instances
2. e2-small (940m allocatable) saturates easily - good for testing, bad for production
3. Always verify alert filters match actual resource types
4. Dashboard and alert should use same metric for consistency

---

## Cleanup

- [x] Stress workload deleted
- [x] GKE cluster destroyed
- [x] Terraform state reconciled
