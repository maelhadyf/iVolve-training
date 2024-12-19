


---

# DaemonSets

## Purpose:
- Ensures that **all (or some)** nodes run a copy of a pod.
- Automatically creates pods on **new nodes** when added to the cluster.
- Automatically removes pods when **nodes are removed** from the cluster.

## Use Cases:
- **Node monitoring tools**
- **Log collectors**

---

# Taints & Tolerations

## Purpose:
- **Taints** are applied to nodes to **repel** certain pods.
- **Tolerations** are applied to pods to **allow** them to be scheduled on tainted nodes.
- Acts as a **restriction mechanism** for pod scheduling.

## Use Cases:
- **Dedicated nodes for specific workloads**
- **Restricting pod placement** on certain nodes
- Special hardware requirements

---

# Node Affinity

## Purpose:
- Attracts pods to **specific nodes** based on **node labels**.
- Provides more **expressive pod placement rules**.
- Offers both **hard (required)** and **soft (preferred)** placement rules.

## Use Cases:
- **Workload placement** based on node characteristics.
- **Hardware requirements** (e.g., GPU, SSD).
- **Geographic location requirements**.
- **Performance optimization** (e.g., placing pods on nodes with better performance).

---
