# 🛡️ Kubernetes Network Policies

Network Policies act as a firewall for your pods. By default, all pods in Kubernetes can talk to each other. Network Policies restricting this traffic.

## 🔑 Key Concepts
*   **Default Allow**: If no policy exists, traffic is allowed.
*   **Default Deny**: A "catch-all" policy that blocks everything so you can whitelist specific traffic.
*   **Ingress**: Incoming traffic.
*   **Egress**: Outgoing traffic.

## 🛠️ Hands-on Exercise

1.  **Deny All Traffic**: Apply `01-deny-all.yaml` to block all communication in the namespace.
2.  **Allow Web Traffic**: Apply `02-allow-web.yaml` to allow traffic only on port 80.
