# 🔐 Kubernetes RBAC (Role-Based Access Control)

## 🎯 Learning Objectives
- Understand the 4 pillars of RBAC: **Role**, **ClusterRole**, **RoleBinding**, **ClusterRoleBinding**
- Learn how to restrict user/pod access to specific resources
- Practice creating a restricted user that can only "read" pods but not "delete" them

---

## 📚 Core Concepts

RBAC answers the question: **"Can this Subject (User/Group) perform this Action (Verb) on this Object (Resource)?"**

### The 4 Pillars

| Resource | Scope | Description | Analogy |
|----------|-------|-------------|---------|
| **Role** | Namespace | Defines *what* can be done (e.g., "can read pods") | A Job Description (e.g., "Cashier") |
| **RoleBinding** | Namespace | Connects a *Role* to a *Subject* (User/SA) | Hiring a person as a Cashier in *this* store |
| **ClusterRole** | Cluster-wide | Defines permissions across ALL namespaces | A Regional Manager Job Description |
| **ClusterRoleBinding**| Cluster-wide | Connects a *ClusterRole* to a *Subject* | Hiring a Regional Manager for the whole company |

### 1. Role vs ClusterRole
- **Role**: "I can read secrets in the `dev` namespace"
- **ClusterRole**: "I can read nodes (nodes are global)" OR "I can read secrets in ALL namespaces"

### 2. Subjects (Who?)
- **User**: Humans (e.g., `veera`)
- **Group**: Set of users (e.g., `devs`)
- **ServiceAccount**: Scripts/Pods running in the cluster

---

## 🛠️ The Workflow

1. **Create a Role**: Define permissions
   ```yaml
   rules:
   - apiGroups: [""]
     resources: ["pods"]
     verbs: ["get", "list", "watch"]
   ```
2. **Create a ServiceAccount**: This acts as our "test user"
3. **Create a RoleBinding**: Link the SA to the Role
4. **Verify**: Use `kubectl auth can-i` to check permissions

---

## 📁 Files in This Module

| File | Description |
|------|-------------|
| `00-service-account.yaml` | Creates a ServiceAccount strictly for testing |
| `01-role.yaml` | Defines a "Pod Reader" role (Read-only access) |
| `02-rolebinding.yaml` | Assigns the "Pod Reader" role to our ServiceAccount |
| `03-clusterrole-view.yaml` | Example of a global read-only role |

---

## 🚀 Quick Start Commands

```bash
# Step 1: Create the namespace for testing
kubectl create ns rbac-demo

# Step 2: Create a Service Account (our test user)
kubectl apply -f 00-service-account.yaml

# Step 3: Check if the new user can list pods? (Should be NO)
kubectl auth can-i list pods --as=system:serviceaccount:rbac-demo:dev-user -n rbac-demo
# Output: no

# Step 4: Create the Role (The Permission Definition)
kubectl apply -f 01-role.yaml

# Step 5: Bind the Role to the User
kubectl apply -f 02-rolebinding.yaml

# Step 6: Verify Access Again (Should be YES)
kubectl auth can-i list pods --as=system:serviceaccount:rbac-demo:dev-user -n rbac-demo
# Output: yes

# Step 7: Verify "Delete" Access (Should still be NO)
kubectl auth can-i delete pods --as=system:serviceaccount:rbac-demo:dev-user -n rbac-demo
# Output: no
```

---

## 🧹 Cleanup
```bash
kubectl delete ns rbac-demo
```
