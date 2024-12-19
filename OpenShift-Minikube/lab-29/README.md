# Lab 27: Updating Applications and Rolling Back Changes

Deploy NGINX with 3 replicas.  
Create a service to expose NGINX deployment and use port forwarding to access NGINX service locally.  
Update NGINX image in the deployment to Apache image.  
View deployment's rollout history.  
Roll back NGINX deployment to the previous image version and Monitor pod status to confirm successful rollback.  


---


## 🏃‍♂️ Running
save the next demo script:
```bash
# Make it executable
chmod +x updating_rolling_back_demo.sh

# Run the script
./updating_rolling_back_demo.sh
```

```bash

#!/bin/bash

# Function for pausing between steps
pause() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Function to display step information
show_step() {
    echo
    echo "=========================================="
    echo "Step $1: $2"
    echo "=========================================="
    echo
}

# Function to watch deployment changes (runs for 30 seconds)
watch_deployment() {
    echo "Watching deployment changes for 30 seconds..."
    timeout 30 kubectl get pods -w
}

# Function to update port forwarding
update_port_forward() {
    # Kill existing port forward if it exists
    if [ ! -z "$PORT_FORWARD_PID" ]; then
        kill $PORT_FORWARD_PID 2>/dev/null
    fi
    # Start new port forwarding
    kubectl port-forward service/nginx-service 8080:80 &
    PORT_FORWARD_PID=$!
    echo "Port forwarding updated. You can access the service at http://localhost:8080"
    echo "Port forwarding PID: $PORT_FORWARD_PID"
    # Give port forwarding a moment to establish
    sleep 3
}

# Step 1: Create and apply NGINX deployment
show_step "1" "Creating and applying NGINX deployment"
cat << 'EOF' > nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  annotations:
    kubernetes.io/change-cause: "Initial deployment with nginx:latest"
spec:
  replicas: 3
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
        ports:
        - containerPort: 80
EOF
kubectl apply -f nginx-deployment.yaml
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/nginx-deployment --timeout=60s
pause

# Step 2: Create and apply service
show_step "2" "Creating and applying NGINX service"
cat << 'EOF' > nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
kubectl apply -f nginx-service.yaml
echo "Service created."
pause

# Step 3: Check initial deployment status
show_step "3" "Checking initial deployment status"
kubectl get pods
kubectl get services
pause

# Step 4: Start initial port forwarding
show_step "4" "Starting port forwarding"
update_port_forward
echo "You can now access NGINX at http://localhost:8080"
pause

# Step 5: Update to Apache image with annotation and watch changes
show_step "5" "Updating deployment to Apache image and watching changes"
echo "Current pod status:"
kubectl get pods
echo
echo "Updating image and watching changes..."
kubectl annotate deployment/nginx-deployment kubernetes.io/change-cause="Updating to httpd:latest"

# Start watching in background
watch_deployment &
WATCH_PID=$!

# Perform the update
kubectl set image deployment/nginx-deployment nginx=httpd:latest

# Wait for deployment to complete
kubectl wait --for=condition=available deployment/nginx-deployment --timeout=60s

# Wait for the watch to complete
wait $WATCH_PID

echo "Image update completed."
echo "Current pod status:"
kubectl get pods

# Update port forwarding to show Apache
echo "Updating port forwarding to show Apache..."
update_port_forward
pause

# Step 6: View rollout history
show_step "6" "Viewing rollout history"
kubectl rollout history deployment/nginx-deployment
pause

# Step 7: Rollback to previous version with annotation and watch changes
show_step "7" "Rolling back to previous version and watching changes"
echo "Current pod status:"
kubectl get pods
echo
echo "Rolling back and watching changes..."
kubectl annotate deployment/nginx-deployment kubernetes.io/change-cause="Rolling back to nginx:latest"

# Start watching in background
watch_deployment &
WATCH_PID=$!

# Perform the rollback
kubectl rollout undo deployment/nginx-deployment

# Wait for deployment to complete
kubectl wait --for=condition=available deployment/nginx-deployment --timeout=60s

# Wait for the watch to complete
wait $WATCH_PID

echo "Rollback completed."
echo "Current pod status:"
kubectl get pods

# Update port forwarding to show NGINX again
echo "Updating port forwarding to show NGINX..."
update_port_forward
pause

# Step 8: Monitor pod status and view final history
show_step "8" "Final deployment status"
kubectl get pods
kubectl describe deployment nginx-deployment | grep Image
echo "Final rollout history:"
kubectl rollout history deployment/nginx-deployment
pause

# Step 9: Cleanup
show_step "9" "Cleaning up resources"
# Kill port forwarding
kill $PORT_FORWARD_PID
# Delete resources
kubectl delete -f nginx-deployment.yaml
kubectl delete -f nginx-service.yaml
echo "Cleanup completed."

echo
echo "Demo completed!"


```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
