# 🧶 Kustomize

Kustomize lets you customize raw, template-free YAML files for multiple purposes (dev, staging, prod), leaving the original YAML untouched.

## 📌 Structure
*   **Base**: The common configuration.
*   **Overlays**: Environment-specific patches (e.g., more replicas in Prod).

## 🛠️ Usage
See the `base` and `overlays` directories (placeholders).
Run: `kubectl kustomize overlays/dev`
