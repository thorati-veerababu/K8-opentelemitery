# 📦 Helm - The Kubernetes Package Manager

## 🎯 What is Helm?

**Helm** is like `apt` or `yum` or `homebrew` but for Kubernetes.

Instead of writing 10 YAML files for every app, you bundle them into a **Chart**.

```
┌─────────────────────────────────────────────────────────────────┐
│                    YAML vs HELM                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   YAML (Hard Way):                                              │
│   ├── deployment.yaml (Lines: 50)                               │
│   ├── service.yaml    (Lines: 20)                               │
│   ├── ingress.yaml    (Lines: 30)                               │
│   └── configmap.yaml  (Lines: 15)                               │
│   (Total: 115 lines, hard coded values)                         │
│                                                                  │
│   Helm (Smart Way):                                             │
│   ├── templates/ (Logic)                                        │
│   │   ├── deployment.yaml: "replicas: {{ .Values.replicas }}"   │
│   └── values.yaml (Config)                                      │
│       └── replicas: 3                                           │
│                                                                  │
│   Deploy: `helm install my-app ./chart`                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| **Chart** | A package of pre-configured K8s resources |
| **Release** | A running instance of a Chart (installed app) |
| **Repository** | A library of shareable Charts (like Docker Hub) |
| **Templates** | YAML files with dynamic placeholders (`{{ .Values }}`) |
| **Values** | The configuration file (`values.yaml`) |

---

## 📋 Files in This Module

We will create a full **Chart Structure**:

```
06-helm/
├── my-first-chart/
│   ├── Chart.yaml          # Metadata (name, version)
│   ├── values.yaml         # Default configuration
│   └── templates/          # Logic
│       ├── _helpers.tpl    # Reusable snippets
│       ├── deployment.yaml # Deployment template
│       └── service.yaml    # Service template
```

---

## 🚀 Quick Start Commands

```bash
# 1. Create a Chart
helm create my-chart

# 2. Install it
helm install demo ./my-chart

# 3. Upgrade it (Change config on fly!)
helm upgrade demo ./my-chart --set replicaCount=5

# 4. Uninstall
helm uninstall demo
```
