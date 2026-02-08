# 🚑 Disaster Recovery (DR) with Velero

Backing up your Kubernetes cluster resources and Persistent Volumes.

## 📌 Velero
Velero is the standard tool for K8s backups.
*   **Backup**: Saves YAMLs and EBS snapshots to S3.
*   **Restore**: Brings them back in case of cluster deletion.

## 🛠️ Usage (Conceptual)
```bash
# Backup
velero backup create my-backup --include-namespaces=my-app

# Restore
velero restore create --from-backup my-backup
```
