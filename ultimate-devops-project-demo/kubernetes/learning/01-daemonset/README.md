# 🔄 DaemonSet - Run a Pod on Every Node

## 🎯 What is a DaemonSet?

A **DaemonSet** ensures that **one copy of a pod runs on every node** in the cluster.

```
┌─────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Node 1              Node 2              Node 3                │
│  ┌──────────┐        ┌──────────┐        ┌──────────┐          │
│  │ [App Pod]│        │ [App Pod]│        │ [App Pod]│          │
│  │ [App Pod]│        │ [App Pod]│        │          │          │
│  │          │        │          │        │          │          │
│  │┌────────┐│        │┌────────┐│        │┌────────┐│          │
│  ││DaemonS ││        ││DaemonS ││        ││DaemonS ││          │
│  ││  Pod   ││        ││  Pod   ││        ││  Pod   ││          │
│  │└────────┘│        │└────────┘│        │└────────┘│          │
│  └──────────┘        └──────────┘        └──────────┘          │
│       ▲                   ▲                   ▲                 │
│       └───────────────────┴───────────────────┘                 │
│                    ONE POD PER NODE                              │
│                  (Automatic placement!)                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 When to Use DaemonSet?

| Use Case | Example |
|----------|---------|
| **Log collection** | Fluentd, Filebeat, Promtail |
| **Monitoring agents** | Node Exporter, Datadog Agent |
| **Network plugins** | Calico, Cilium |
| **Storage drivers** | CSI node plugins (you already have these!) |

---

## 🔍 DaemonSets in Your Cluster

You already have DaemonSets running! Check:

```bash
kubectl get daemonset -A
```

Expected output:
- `aws-node` - AWS VPC CNI (networking)
- `kube-proxy` - Kubernetes network proxy
- `ebs-csi-node` - EBS storage on each node
- `efs-csi-node` - EFS storage on each node

---

## 📋 Files in This Module

| File | Description |
|------|-------------|
| `01-daemonset-logger.yaml` | Simple logging agent example |
| `02-daemonset-node-exporter.yaml` | Monitoring agent example |
| `03-daemonset-with-tolerations.yaml` | Run on ALL nodes including control plane |

---

## ✅ Key Concepts

| Concept | Description |
|---------|-------------|
| **Automatic scheduling** | Pods placed on nodes automatically |
| **New node = new pod** | When node joins, DaemonSet pod appears |
| **Node removal** | Pod garbage collected |
| **Node selector** | Run only on specific nodes |
| **Tolerations** | Run on tainted nodes (control plane) |

---

## 🚀 Quick Start

```bash
# Apply the DaemonSet
kubectl apply -f 01-daemonset-logger.yaml

# Check pods on each node
kubectl get pods -o wide -l app=node-logger

# See the DaemonSet status
kubectl get daemonset node-logger
```
