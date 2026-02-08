# 🛡️ Kubernetes Pod Security (SecurityContext)

## 🎯 Learning Objectives
- Understand why running as **Root** is dangerous
- Learn how to use **SecurityContext** to lock down pods
- Implement **Read-Only Filesystems** and **Drop Capabilities**

---

## 📚 Core Concepts

By default, containers in Kubernetes are **insecure**. They often run as `root` (UID 0), which means if a hacker breaks out of the container, they are `root` on your node!

### The SecurityContext
The `securityContext` field in your YAML is where you define these rules. It can be set at the **Pod level** (for all containers) or **Container level**.

### Top 3 Best Practices

1.  **RunAsNonRoot**: Ensure the app *never* runs as root.
2.  **ReadOnlyRootFilesystem**: Prevent the app from writing to disk (except specific volumes). Hackers can't download malware if they can't write!
3.  **Drop Capabilities**: Remove Linux powers like `NET_ADMIN` (modifying network) or `SYS_TIME` (changing time).

---

## 📁 Files in This Module

| File | Description |
|------|-------------|
| `01-insecure-pod.yaml` | A typical "bad" pod running as root |
| `02-secure-pod.yaml` | A "good" pod with full security context |

---

## 🚀 Quick Start Commands

```bash
# Step 1: Run the INSECURE pod
kubectl apply -f 01-insecure-pod.yaml

# Step 2: Check who is running inside (It will be 'root')
kubectl exec -it insecure-pod -- whoami
# Output: root (BAD! ❌)

# Step 3: Run the SECURE pod
kubectl apply -f 02-secure-pod.yaml

# Step 4: Check who is running inside
kubectl exec -it secure-pod -- whoami
# Output: 1000 (GOOD! ✅)

# Step 5: Try to create a file in secure pod
kubectl exec -it secure-pod -- touch /tmp/hacker.sh
# Output: Read-only file system (SECURE! 🔒)
```
