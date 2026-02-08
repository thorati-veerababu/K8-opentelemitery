# 📈 Horizontal Pod Autoscaler (HPA)

## 🎯 What is HPA?

**HPA** automatically scales the number of pods in a deployment based on observed CPU utilization (or other metrics).

```
┌─────────────────────────────────────────────────────────────────┐
│                       Load Increase! 🚀                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Time 12:00 (Low Traffic)                                      │
│   ┌──────┐                                                      │
│   │ Pod  │  CPU: 10%                                            │
│   └──────┘                                                      │
│                                                                  │
│   Time 12:05 (High Traffic!)                                    │
│   ┌──────┐                                                      │
│   │ Pod  │  CPU: 95% 🚨 (Creating more pods...)                 │
│   └──────┘                                                      │
│       │                                                          │
│       ▼                                                          │
│   Time 12:06 (HPA Action)                                       │
│   ┌──────┐   ┌──────┐   ┌──────┐  ┌──────┐                      │
│   │ Pod  │   │ Pod  │   │ Pod  │  │ Pod  │                      │
│   └──────┘   └──────┘   └──────┘  └──────┘                      │
│   CPU: 25%   CPU: 25%   CPU: 25%  CPU: 25%                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

1.  **Metrics Server**: Must be installed! HPA needs to know CPU usage.
    *   Check: `kubectl top nodes`
2.  **Resource Requests**: Pods MUST have CPU requests defined (`resources.requests.cpu`).

---

## 📋 Files in This Module

| File | Description |
|------|-------------|
| `01-hpa-deployment.yaml` | PHP Apache server (CPU intensive) |
| `02-hpa.yaml` | HPA rule (Target 50% CPU, Max 10 Pods) |
| `03-load-generator.yaml` | Pod that sends infinite traffic |

---

## 🚀 Quick Start

```bash
# 1. Apply Deployment & Service
kubectl apply -f 01-hpa-deployment.yaml

# 2. Apply HPA
kubectl apply -f 02-hpa.yaml

# 3. Generate Load
kubectl apply -f 03-load-generator.yaml

# 4. Watch it Scale!
kubectl get hpa -w
```
