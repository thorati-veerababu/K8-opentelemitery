# 📦 Kubernetes Storage: PV, PVC & StorageClass

## 🎯 Learning Objectives
- Understand how Kubernetes handles persistent storage
- Create and use Persistent Volumes (PV) and Claims (PVC)
- Learn about StorageClasses and dynamic provisioning
- Practice with EBS storage on EKS

---

## 📚 Core Concepts

### The Storage Problem
Pods are **ephemeral** (temporary). When a pod dies, all data inside dies with it.
For databases, logs, or any data that must survive pod restarts, we need **Persistent Storage**.

### The Solution: PV, PVC, StorageClass

```
┌────────────────────────────────────────────────────────────────────────┐
│                         KUBERNETES CLUSTER                              │
│                                                                         │
│   ┌─────────────┐                                                       │
│   │     Pod     │                                                       │
│   │  ┌───────┐  │     "I need                                          │
│   │  │ App   │  │      storage"                                        │
│   │  └───┬───┘  │         │                                            │
│   └──────┼──────┘         ▼                                            │
│          │         ┌─────────────┐      binds       ┌───────────────┐  │
│          │         │     PVC     │ ───────────────► │      PV       │  │
│          │         │   (Claim)   │                  │   (Storage)   │  │
│          │         │             │                  │               │  │
│          └────────►│ "5Gi, RWO"  │                  │  "5Gi on EBS" │  │
│                    └─────────────┘                  └───────┬───────┘  │
│                                                             │          │
│                    ┌─────────────────┐                      │          │
│                    │  StorageClass   │◄─────────────────────┘          │
│                    │   (Template)    │                                 │
│                    │ "Use EBS gp3"   │                                 │
│                    └────────┬────────┘                                 │
│                             │                                          │
└─────────────────────────────┼──────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   AWS EBS       │
                    │  (Actual Disk)  │
                    └─────────────────┘
```

---

## 🔑 Key Terms

| Term | Full Name | What It Does | AWS Equivalent |
|------|-----------|--------------|----------------|
| **PV** | Persistent Volume | Actual storage resource in cluster | Like an EBS volume |
| **PVC** | Persistent Volume Claim | Request for storage by a pod | "I need X GB" |
| **SC** | StorageClass | Template for creating PVs | "Use gp3 SSD, io1, etc." |
| **CSI** | Container Storage Interface | Plugin to connect K8s with cloud storage | EBS/EFS drivers |

---

## 📋 Access Modes

| Mode | Short | Description | Use Case |
|------|-------|-------------|----------|
| ReadWriteOnce | RWO | One node can read/write | Databases (MySQL, PostgreSQL) |
| ReadOnlyMany | ROX | Many nodes can read | Shared config files |
| ReadWriteMany | RWX | Many nodes can read/write | Shared uploads, CMS |

> ⚠️ **EBS only supports RWO** (one node at a time)
> ✅ **EFS supports RWX** (multiple nodes)

---

## 📁 Files in This Module

| File | Description |
|------|-------------|
| `01-storageclass.yaml` | Define how storage is provisioned |
| `02-pvc.yaml` | Request storage (dynamic provisioning) |
| `03-pod-with-pvc.yaml` | Pod that uses the PVC |
| `04-static-pv.yaml` | Manual PV creation (static provisioning) |

---

## 🚀 Quick Start Commands

```bash
# Step 1: Check if EBS CSI Driver is installed
kubectl get pods -n kube-system | grep ebs

# Step 2: Apply StorageClass
kubectl apply -f 01-storageclass.yaml

# Step 3: Create PVC (this auto-creates PV via dynamic provisioning)
kubectl apply -f 02-pvc.yaml

# Step 4: Check PVC status (should be "Bound")
kubectl get pvc

# Step 5: Deploy pod that uses storage
kubectl apply -f 03-pod-with-pvc.yaml

# Step 6: Verify data persistence
kubectl exec -it storage-test-pod -- cat /data/testfile.txt
```

---

## 🔧 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| PVC stuck in "Pending" | No StorageClass or CSI driver | Install EBS CSI driver |
| Pod can't mount | PVC not bound | Check `kubectl describe pvc` |
| "Volume not found" | Wrong availability zone | Ensure node and volume in same AZ |

---

## 📖 Next Steps
After completing this module:
1. ✅ PV & PVC - You are here!
2. ➡️ StatefulSet - Uses PVC templates for databases
3. ➡️ Volume Snapshots - Backup your data
