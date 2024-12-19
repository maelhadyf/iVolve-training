


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

## 🏃‍♂️ Running
save the next demo script:
```bash
# Make it executable
chmod +x daemonSet-taint-toleration-demo.sh

# Run the script
./daemonSet-taint-toleration-demo.sh
```

```bash
#!/bin/bash

# Colors for better output visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set namespace name
NAMESPACE="taint-demo"

# Function to print colored output
print_message() {
    echo -e "\n${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "\n${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "\n${RED}[ERROR]${NC} $1"
}

# Function to wait for pod status
wait_for_pod() {
    local pod_name=$1
    local desired_status=$2
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        status=$(kubectl get pod $pod_name -n $NAMESPACE -o jsonpath='{.status.phase}' 2>/dev/null)
        if [ "$status" == "$desired_status" ]; then
            return 0
        fi
        sleep 2
        ((attempt++))
    done
    return 1
}

# Create temporary YAML files
create_yaml_files() {
    print_message "Creating YAML files..."

    # Create namespace YAML
    cat << EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOF

    # Create DaemonSet YAML
    cat << EOF > nginx-ds.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  namespace: $NAMESPACE
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
EOF

    # Create Pod with blue toleration
    cat << EOF > pod-blue.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-blue
  namespace: $NAMESPACE
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
EOF

    # Create Pod with red toleration
    cat << EOF > pod-red.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-red
  namespace: $NAMESPACE
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "red"
    effect: "NoSchedule"
EOF

    print_success "YAML files created successfully"
}

# Clean up resources
cleanup() {
    print_message "Cleaning up resources..."
    
    # Delete namespace (this will delete all resources in the namespace)
    kubectl delete namespace $NAMESPACE --timeout=60s 2>/dev/null
    
    # Remove taint from node
    kubectl taint nodes minikube color:NoSchedule- 2>/dev/null
    
    # Remove YAML files
    rm -f namespace.yaml nginx-ds.yaml pod-blue.yaml pod-red.yaml
    
    print_success "Cleanup completed"
}

# Main demo
main() {
    # Cleanup any existing resources
    cleanup

    # Create YAML files
    create_yaml_files

    # Step 1: Create namespace
    print_message "Creating namespace: $NAMESPACE"
    kubectl apply -f namespace.yaml
    sleep 2

    # Step 2: Create DaemonSet
    print_message "Creating DaemonSet in namespace: $NAMESPACE"
    kubectl apply -f nginx-ds.yaml
    sleep 5

    print_message "DaemonSet pods status:"
    kubectl get pods -n $NAMESPACE

    # Step 3: Taint the Minikube node
    print_message "Tainting Minikube node with color=red:NoSchedule"
    kubectl taint nodes minikube color=red:NoSchedule
    sleep 2

    # Step 4: Create pod with blue toleration
    print_message "Creating pod with color=blue toleration..."
    kubectl apply -f pod-blue.yaml
    sleep 5

    print_message "Status of pod with blue toleration:"
    kubectl get pod nginx-pod-blue -n $NAMESPACE

    # Step 5: Create pod with red toleration
    print_message "Creating pod with color=red toleration..."
    kubectl apply -f pod-red.yaml
    sleep 5

    print_message "Status of all pods in namespace $NAMESPACE:"
    kubectl get pods -n $NAMESPACE

    # Wait for red pod to be running
    if wait_for_pod "nginx-pod-red" "Running"; then
        print_success "Pod with red toleration is running successfully"
    else
        print_error "Pod with red toleration failed to reach Running state"
    fi

    # Show all resources in the namespace
    print_message "All resources in namespace $NAMESPACE:"
    echo "Pods:"
    kubectl get pods -n $NAMESPACE
    echo -e "\nDaemonSets:"
    kubectl get ds -n $NAMESPACE

    print_message "Demo completed! Here's what we observed:"
    echo "1. Created namespace: $NAMESPACE"
    echo "2. DaemonSet pods continued running even after adding the taint"
    echo "3. Pod with color=blue toleration remained in Pending state"
    echo "4. Pod with color=red toleration was scheduled successfully"
    echo "5. All resources are contained within namespace: $NAMESPACE"

    print_message "Would you like to cleanup the resources?"
    read -p "Delete namespace $NAMESPACE? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
}

# Run the demo
main

```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
