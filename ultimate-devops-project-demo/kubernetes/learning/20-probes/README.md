# 🏥 Kubernetes Probes: Liveness, Readiness, & Startup

Probes are health checks that run inside your pods. They tell Kubernetes the state of your application.

## 📌 Types of Probes

### 1. `livenessProbe` (The "Restart" Button)
- **Checks:** Is the container running/alive?
- **Action on Failure:** Kills and **RESTARTS** the container.
- **Use Case:** Deadlocks, crash loops, frozen app.

### 2. `readinessProbe` (The "Traffic" Gate)
- **Checks:** Is the app ready to accept traffic?
- **Action on Failure:** Removes pod from Service endpoints (stops sending traffic). **Does NOT restart.**
- **Use Case:** App is starting up, loading large data, or temporarily overloaded.

### 3. `startupProbe` (The "Slow Start" Guard)
- **Checks:** Has the app started successfully?
- **Action on Failure:** Kills and restarts the container.
- **Note:** Disables other probes until it succeeds.
- **Use Case:** Legacy apps that take minutes to boot.

## 🛠️ Hands-on Exercise

1.  **Deploy the Probes Demo**:
    ```bash
    kubectl apply -f 01-probes-demo.yaml
    ```

2.  **Observe Behavior**:
    - The `liveness` pod will restart if the file `/tmp/healthy` is deleted.
    - The `readiness` pod will not receive traffic until the file exists.

3.  **Break it!**
    ```bash
    # Kill the liveness pod
    kubectl exec -it <liveness-pod> -- rm /tmp/healthy
    # Watch it restart
    kubectl get pods -w
    ```
