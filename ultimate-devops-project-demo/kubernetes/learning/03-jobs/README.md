# ⏱️ Jobs & CronJobs - Batch Processing

## 🎯 What are Jobs?

A **Job** creates one or more Pods and ensures that a specified number of them **successfully terminate**.

- **Pod vs Job**: 
  - Pod: Run forever (web server)
  - Job: Run to completion (batch script, database migration)

## 🎯 What are CronJobs?

A **CronJob** creates Jobs on a repeating schedule (like Linux `cron`).

```
┌─────────────────────────────────────────────────────────────────┐
│                    JOB vs CRONJOB                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Job: "Run this script once, right now."                       │
│   ┌─────────────┐                                               │
│   │  Job        │ ──► [Pod] (Runs → Completes)                  │
│   └─────────────┘                                               │
│                                                                  │
│   CronJob: "Run this script every night at midnight."           │
│   ┌─────────────┐       ┌─────┐                                 │
│   │  CronJob    │ ──┬─► │ Job │ ──► [Pod] (Day 1)               │
│   │ "0 0 * * *" │   │   └─────┘                                 │
│   │             │   │   ┌─────┐                                 │
│   └─────────────┘   └─► │ Job │ ──► [Pod] (Day 2)               │
│                         └─────┘                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Use Cases

| Resource | Use Case |
|----------|----------|
| **Job** | - Database schema migration<br>- Initial data loading<br>- Batch image processing |
| **CronJob** | - Daily backups<br>- Report generation<br>- Sending email digests<br>- Cleanup scripts |

---

## 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| **Completions** | How many times the pod must succeed |
| **Parallelism** | How many pods run at the same time |
| **BackoffLimit** | How many retries before failing the Job |
| **Schedule** | Cron format (e.g., `* * * * *` for every minute) |

---

## 📋 Files in This Module

| File | Description |
|------|-------------|
| `01-simple-job.yaml` | A job that counts down and exits |
| `02-job-parallel.yaml` | A job running multiple pods in parallel |
| `03-cronjob.yaml` | A scheduled job running every minute |

---

## 🚀 Quick Start

```bash
# Run a one-off job
kubectl apply -f 01-simple-job.yaml
kubectl logs job/simple-job

# Run a scheduled job
kubectl apply -f 03-cronjob.yaml
kubectl get cronjob
# Wait a minute to see jobs appearing...
```
