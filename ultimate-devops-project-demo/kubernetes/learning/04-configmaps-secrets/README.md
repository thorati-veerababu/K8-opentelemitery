# 🗝️ ConfigMaps & Secrets - Configuration Management

## 🎯 What are they?

- **ConfigMap**: Stores **non-sensitive** data (config files, environment variables, hostname settings).
- **Secret**: Stores **sensitive** data (passwords, API keys, certificates). stored base64 encoded.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Separation of Concerns                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐   │
│   │ ConfigMap   │       │     Pod     │       │    Secret   │   │
│   │ "app-config"│ ◄───  │  (App)      │  ───► │ "db-pass"   │   │
│   │             │       │             │       │             │   │
│   │ color=blue  │       │ APP_COLOR   │       │ DB_PASSWORD │   │
│   │ debug=true  │       │     =       │       │      =      │   │
│   └─────────────┘       │    blue     │       │   s3cr3t    │   │
│                         └─────────────┘       └─────────────┘   │
│                                                                  │
│   The Image (Pod) stays generic.                                 │
│   Configuration is injected at runtime!                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Ways to Use Them

1.  **Environment Variables**: Inject single values (`DB_HOST`, `DB_USER`).
2.  **Volume Mounts**: Inject entire files (`nginx.conf`, `settings.json`).
3.  **Command Arguments**: Pass values to startup command.

---

## 🔑 Secret Types

| Type | Use Case |
|------|----------|
| `Opaque` | Arbitrary user-defined data (passwords, keys) - Default |
| `kubernetes.io/dockerconfigjson` | Private Docker registry credentials |
| `kubernetes.io/tls` | TLS Certificates for Ingress/HTTPS |

---

## 📋 Files in This Module

| File | Description |
|------|-------------|
| `01-configmap.yaml` | Creates a ConfigMap with env vars and a file |
| `02-secret.yaml` | Creates a Secret (base64 encoded) |
| `03-pod-with-config.yaml` | Pod using both CM and Secret |

---

## 🚀 Quick Start

```bash
# Apply ConfigMap & Secret
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-secret.yaml

# Create the Pod
kubectl apply -f 03-pod-with-config.yaml

# Verify Environment Variables
kubectl exec config-demo -- env | grep APP_

# Verify Mounted File
kubectl exec config-demo -- cat /config/game.properties
```
