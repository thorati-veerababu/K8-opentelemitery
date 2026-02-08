# 🐤 Canary Deployments

Gradually shifting traffic to a new version of your app to reduce risk.

## 📌 Tools
*   **Argo Rollouts**: Replaces `Deployment` object with `Rollout`.
*   **Flagger**: Works with Service Meshes (Istio) to shift traffic.

## 🛠️ Workflow
1.  Deploy v1 (100% traffic).
2.  Deploy v2.
3.  Shift 10% traffic to v2.
4.  If metrics (success rate) are good, shift 50% -> 100%.
5.  If bad, rollback.
