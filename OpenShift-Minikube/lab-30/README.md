# Lab 30: OpenShift Security and RBAC

Create a Service Account.   
Define a Role named pod-reader allowing read-only access to pods in the namespace.   
Bind the pod-reader Role to the Service Account and get ServiceAccount token.   
Make a Comparison between service account - role & role binding - and cluster role & cluster role binding.  

---

# Comparison Between Service Account, Role & Role Binding, and Cluster Role & Cluster Role Binding

## 1. **ServiceAccount**
### Purpose:
- **ServiceAccount** is used to provide an identity to a pod or a set of pods to interact with the Kubernetes API.
- It is associated with an **API token** which can be used by applications running inside the pod to authenticate and authorize API requests.

### Key Points:
- By default, each pod gets a default service account unless specified otherwise.
- Service accounts are tied to namespaces.
- Provides access to the Kubernetes API based on the associated roles and permissions.

### Use Cases:
- Assigning roles and permissions to applications running inside pods to interact with Kubernetes resources.

---

## 2. **Role & RoleBinding**
### **Role**:
- A **Role** is a set of permissions (rules) granted within a specific namespace.
- It defines what actions (verbs) can be performed on which resources (e.g., Pods, Services, ConfigMaps) within the namespace.

### **RoleBinding**:
- **RoleBinding** is used to bind a Role to a user, group, or service account within a specific namespace.
- It grants the permissions defined in a Role to a particular entity (e.g., service account, user).

### Key Points:
- **Role** is **namespace-scoped**.
- **RoleBinding** binds the **Role** to a specific user or service account within the namespace.
- A RoleBinding is **not global**; it only applies within the namespace it is defined.

### Use Cases:
- Assigning specific permissions to a service account or user within a namespace.
- Example: Allowing a pod to list and get pods within the same namespace.

---

## 3. **ClusterRole & ClusterRoleBinding**
### **ClusterRole**:
- A **ClusterRole** defines a set of permissions that can be applied **cluster-wide** (not limited to a specific namespace).
- It can be used to grant permissions across multiple namespaces or to cluster-wide resources (e.g., nodes, namespaces, persistent volumes).

### **ClusterRoleBinding**:
- **ClusterRoleBinding** binds a **ClusterRole** to a user, group, or service account across the entire cluster (not tied to a specific namespace).
- It grants the permissions defined in a ClusterRole to an entity at the cluster level.

### Key Points:
- **ClusterRole** is **cluster-scoped**.
- **ClusterRoleBinding** is used to assign **ClusterRoles** to users, groups, or service accounts across the entire cluster.
- ClusterRoles can be used for namespace-specific resources as well as cluster-wide resources.

### Use Cases:
- Assigning global permissions to a service account or user.
- Example: Giving a user permission to create and delete namespaces across the cluster.

---

### **Key Differences:**

| Feature                     | **ServiceAccount**                                 | **Role & RoleBinding**                               | **ClusterRole & ClusterRoleBinding**                    |
|-----------------------------|----------------------------------------------------|-----------------------------------------------------|--------------------------------------------------------|
| **Scope**                   | Namespace-specific                                 | Namespace-specific                                  | Cluster-wide                                           |
| **Resources Affected**      | Allows pods to authenticate with Kubernetes API    | Defines access to resources within a namespace      | Defines access to resources across the entire cluster  |
| **Binding**                 | Not directly bound to permissions                  | Binds a user/service account to a Role               | Binds a user/service account to a ClusterRole          |
| **Use Case**                | Identity for pods to access Kubernetes API         | Manage permissions within a namespace                | Manage global or cluster-wide permissions              |
| **Example Use**             | Assigning an identity to a pod                     | Granting access to resources (pods, services) in a namespace | Granting access to resources (nodes, namespaces) cluster-wide |

---
