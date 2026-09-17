# Runbook: High CPU Utilization Alert

**Alert Name:** SRE - High CPU Utilization
**Severity:** Warning
**Threshold:** CPU > 80% for 5 minutes
**Dashboard:** SRE Infrastructure Dashboard

---

## Alert Description

This alert fires when a GCE instance or GKE node maintains CPU utilization above 80% for more than 5 minutes. This indicates sustained resource pressure that may impact application performance.

---

## Response Steps

### 1. Acknowledge Alert

- Open Cloud Console → Monitoring → Alerting
- Find the active incident
- Click **Acknowledge** to notify the team you're investigating
- Note the timestamp and affected resource

### 2. Identify Affected Resource

```bash
# List all GCE instances
gcloud compute instances list

# Check which instance is triggering the alert
# The alert condition filters for: resource.type="gce_instance"
# Look for the instance name in the alert notification
```

### 3. Check CPU Timeline

1. Go to **Monitoring → Dashboards → SRE Infrastructure Dashboard**
2. Observe the **VM CPU Utilization** widget
3. Note:
   - When did CPU start rising?
   - Is it a sudden spike or gradual increase?
   - Is it sustained or intermittent?

### 4. Check Logs

```bash
# SSH into the affected instance
gcloud compute ssh <INSTANCE_NAME> --zone=<ZONE>

# Check system processes
top -bn1 | head -20

# Check for application errors
sudo journalctl -u <SERVICE_NAME> --since "1 hour ago" | tail -50

# Check for OOM kills or resource exhaustion
dmesg | grep -i "out of memory"
```

### 5. Check Recent Changes

```bash
# Check recent deployments
kubectl rollout history deployment/<DEPLOYMENT_NAME>  # If GKE

# Check recent config changes
git log --oneline -10  # In the terraform repo

# Check if any scaling events occurred
gcloud compute instance-groups managed list-instances <GROUP_NAME>
```

### 6. Identify Probable Cause

Common causes:
| Symptom | Likely Cause |
|---------|--------------|
| Sudden spike after deploy | Bad deployment, memory leak |
| Gradual increase over days | Traffic growth, no autoscaling |
| Periodic spikes | Cron job, batch processing |
| Spike on all instances | DDoS, external traffic surge |

### 7. Remediate

**If traffic-related:**
```bash
# Scale up instance group
gcloud compute instance-groups managed resize <GROUP_NAME> --size=<NEW_SIZE>
```

**If deployment-related:**
```bash
# Rollback last deployment
kubectl rollout undo deployment/<DEPLOYMENT_NAME>  # If GKE
```

**If rogue process:**
```bash
# Identify and kill the process
ps aux | grep <PROCESS>
kill -9 <PID>
```

### 8. Verify CPU Recovery

1. Return to **SRE Infrastructure Dashboard**
2. Watch the CPU widget for 5-10 minutes
3. Confirm CPU drops below 80%
4. Check alert status changes to **Resolved**

### 9. Document Incident

Create an incident report:

```markdown
## Incident: High CPU - [DATE]

**Duration:** [START] - [END]
**Impact:** [What was affected]
**Root Cause:** [What caused it]
**Remediation:** [What you did]
**Prevention:** [How to prevent recurrence]
```

---

## Escalation

If CPU remains high after remediation:
1. Check for disk I/O bottlenecks
2. Review network metrics
3. Escalate to platform team
4. Consider creating a new instance if host is compromised

---

## Related Resources

- Dashboard: SRE Infrastructure Dashboard
- Alert Policy: `google_monitoring_alert_policy.high_cpu`
- Metrics: `compute.googleapis.com/instance/cpu/utilization`
