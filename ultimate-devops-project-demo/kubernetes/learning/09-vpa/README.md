# ⚖️ Vertical Pod Autoscaler (VPA)

VPA automatically adjusts the CPU and Memory requests/limits for your pods based on historical usage.

## 📌 How it Works
1.  **Recommender**: Monitors metrics history.
2.  **Updater**: Evicts pods that need new resource limits.
3.  **Admission Controller**: Mutates new pods with the recommended limits.

## ⚠️ Important Note
VPA requires the Metrics Server to be installed (which you likely have if you did HPA).

## 🛠️ Example
The `01-vpa.yaml` assumes you have the VPA CRDs installed in your cluster.
