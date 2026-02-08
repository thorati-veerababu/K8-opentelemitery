# 🗄️ StatefulSet - Stable Identity for Stateful Apps

## 🎯 What is a StatefulSet?

A **StatefulSet** manages pods that need:
- **Stable network identity** (consistent pod names)
- **Stable storage** (each pod gets its own PVC)
- **Ordered deployment** (pod-0 before pod-1 before pod-2)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT vs STATEFULSET                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Deployment (Stateless):           StatefulSet (Stateful):     │
│   ┌─────────────┐                   ┌─────────────┐             │
│   │ nginx-abc12 │ Random names      │ mysql-0     │ Predictable │
│   │ nginx-xyz34 │                   │ mysql-1     │             │
│   │ nginx-def56 │                   │ mysql-2     │             │
│   └─────────────┘                   └─────────────┘             │
│         │                                 │                      │
│         ▼                                 ▼                      │
│   ┌─────────────┐                   ┌─────────────┐             │
│   │ Shared PVC  │                   │ PVC-mysql-0 │             │
│   │ (or none)   │                   │ PVC-mysql-1 │             │
│   │             │                   │ PVC-mysql-2 │             │
│   └─────────────┘                   └─────────────┘             │
│         │                                 │                      │
│   All pods same                     Each pod has own             │
│   or no storage                     persistent storage!          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 When to Use StatefulSet?

| Use Case | Why StatefulSet? |
|----------|------------------|
| **Databases** (MySQL, PostgreSQL) | Need stable storage per instance |
| **Message queues** (Kafka, RabbitMQ) | Need stable network identity |
| **Distributed systems** (Zookeeper, etcd) | Need ordered startup |
| **Any app with local state** | Can't share storage between replicas |

---

## 🔑 Key Features

| Feature | Deployment | StatefulSet |
|---------|------------|-------------|
| Pod names | Random (`nginx-abc12`) | Ordered (`mysql-0`, `mysql-1`) |
| Storage | Shared or none | **Each pod gets own PVC** |
| Startup order | Parallel (all at once) | **Sequential** (0→1→2) |
| DNS name | Service only | **Pod-specific DNS** |
| Scaling down | Random deletion | **Reverse order** (2→1→0) |

---

## 📋 Files in This Module

| File | Description |
|------|-------------|
| `01-statefulset-basic.yaml` | Simple StatefulSet example |
| `02-statefulset-with-storage.yaml` | StatefulSet with PVC per pod |
| `03-headless-service.yaml` | Required headless service |

---

## 🚀 Quick Start

```bash
# Apply headless service first (required!)
kubectl apply -f 03-headless-service.yaml

# Apply StatefulSet
kubectl apply -f 01-statefulset-basic.yaml

# Watch pods come up IN ORDER
kubectl get pods -w -l app=web

# Check pod names (should be web-0, web-1, web-2)
kubectl get pods -l app=web
```
