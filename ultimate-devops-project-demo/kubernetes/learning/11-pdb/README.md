# 🛑 Pod Disruption Budget (PDB)

PDBs limit the number of pods of a replicated application that are down simultaneously from voluntary disruptions (like upgrades or draining nodes).

## 📌 Use Case
Ensure high availability during maintenance.
*   "Always keep at least 2 replicas of my database running."
*   "Don't let more than 1 web server go down at a time."

## 🛠️ Example
Use `01-pdb.yaml` to ensure at least 1 replica of `my-app` is always available.
