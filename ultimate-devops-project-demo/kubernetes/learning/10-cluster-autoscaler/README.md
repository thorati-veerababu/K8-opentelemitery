# 📉 Cluster Autoscaler

The Cluster Autoscaler automatically adds or removes nodes (EC2 instances) in your cluster.

## 📌 How it Works
1.  **Scale UP**: If pods are in `Pending` state because no node has enough resources.
2.  **Scale DOWN**: If a node is underutilized and its pods can be moved elsewhere.

## 🛠️ Usage
In EKS, this is typically deployed as a Deployment that talks to AWS Auto Scaling Groups.
(This folder is a placeholder for the concept; the actual installation usually involves IAM roles and Helm charts).
