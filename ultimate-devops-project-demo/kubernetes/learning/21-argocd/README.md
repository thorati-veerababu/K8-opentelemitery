# 🐙 GitOps with ArgoCD

GitOps means using a Git repository as the "source of truth" for your cluster configuration. ArgoCD syncs the cluster state to match Git.

## 📌 Workflow
1.  Push YAML changes to Git.
2.  ArgoCD detects the change.
3.  ArgoCD applies the change to Kubernetes.

## 🛠️ Hands-on
1.  **Install ArgoCD**:
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
2.  **Access UI**:
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
3.  **Define an App**: Use `01-application.yaml`.
