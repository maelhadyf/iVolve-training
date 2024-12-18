## Lab 29: Storage Configuration
Create a deployment named my-deployment with 1 replica using the NGINX image.  
Exec into the NGINX pod and create a file at /usr/share/nginx/html/hello.txt with the content hello, this is <your-name>.  
verify the file is served by NGINX using curl localhost/hello.txt.  
Delete the NGINX pod and wait for the deployment to create a new pod  
Exec into the new pod and verify the file at /usr/share/nginx/html/hello.txt is no longer present.  
Create a PVC and modify the deployment to attach the PVC to the pod at /usr/share/nginx/html.  
Repeat the previous steps and Verify the file persists across pod deletions.  
Make a Comparison between PV, PVC, and StorageClass.  

---

## Comparison between PV, PVC, and StorageClass

![image](https://github.com/user-attachments/assets/50e933c5-5bf3-4c45-8560-95c3507e94b9)


```
|                                   **StorageClass**                                  	|                **Persistent Volume (PV)**                	|    **Persistent Volume Claim (PVC)**    	|
|:-----------------------------------------------------------------------------------:	|:--------------------------------------------------------:	|:---------------------------------------:	|
| - Acts like a storage template or blueprint                                         	| - The actual storage resource in the cluster             	| - A request for storage by a user/pod   	|
| - Defines the type and configuration of storage that can be dynamically provisioned 	| - Like a pre-allocated piece of storage                  	| - Acts as a bridge between pods and PVs 	|
| - Enables automatic creation of Persistent Volumes when needed                      	| - Can be provisioned either:                             	| - Specifies requirements like:          	|
| - Think of it as a "menu" of available storage options in your cluster              	|   - Statically (manually created by admin)               	|   - How much storage is needed          	|
|                                                                                     	|   - Dynamically (automatically created via StorageClass) 	|   - What access modes are required      	|
|                                                                                     	|                                                          	|   - Which StorageClass to use           	|
| **Here's a simple analogy:**                                                        	|                                                          	|                                         	|
| - StorageClass is like a hotel room type (e.g., standard, deluxe, suite)            	|                                                          	|                                         	|
| - PV is like the actual hotel room                                                  	|                                                          	|                                         	|
| - PVC is like a room reservation

```
### StorageClass

- Acts like a storage template or blueprint
- Defines the type and configuration of storage that can be dynamically provisioned
- Enables automatic creation of Persistent Volumes when needed
- Think of it as a "menu" of available storage options in your cluster

### Persistent Volume (PV)

- The actual storage resource in the cluster
- Like a pre-allocated piece of storage
- Can be provisioned either:
  - **Statically** (manually created by admin)
  - **Dynamically** (automatically created via StorageClass)
- Independent of any specific pod's lifecycle

### Persistent Volume Claim (PVC)

- A request for storage by a user/pod
- Acts as a bridge between pods and PVs
- Specifies requirements like:
  - How much storage is needed
  - What access modes are required
  - Which StorageClass to use

### Here's a simple analogy:

- **StorageClass** is like a hotel room type (e.g., standard, deluxe, suite)
- **PV** is like the actual hotel room
- **PVC** is like a room reservation

---

Save the next script as `nginx-persistence-demo.sh` and run it:
```bash
chmod +x nginx-persistence-demo.sh
./nginx-persistence-demo.sh
```

```bash
#!/bin/bash

# Function to wait for pod to be ready
wait_for_pod() {
    echo "\n#### Waiting for pod to be ready..."
    while [[ $(kubectl get pods -l app=nginx -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
        sleep 1
    done
}

# Create deployment
echo "#### Creating deployment..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 1
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
        image: nginx
        ports:
        - containerPort: 80
EOF

# Wait for pod to be ready
wait_for_pod

# Get pod name
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo -e "Pod name: $POD_NAME"

# Create file in pod
echo -e "\n#### Creating file in pod..."
kubectl exec -it $POD_NAME -- bash -c 'echo "hello, king memo..god bless you" > /usr/share/nginx/html/hello.txt'

# Test file access
echo -e "\n#### Testing file access..."
kubectl exec -it $POD_NAME -- curl localhost/hello.txt

# Delete pod
echo -e "\n#### Deleting pod..."
kubectl delete pod $POD_NAME

# Wait for new pod
wait_for_pod

# Get new pod name
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo -e "\nNew pod name: $POD_NAME"

# Try to access file in new pod (should fail)
echo -e "\n#### Trying to access file in new pod (should fail)..."
kubectl exec -it $POD_NAME -- cat /usr/share/nginx/html/hello.txt || echo "File not found as expected"

# Create PVC
echo -e "\n#### Creating PVC..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Update deployment with PVC
echo -e "\n#### Updating deployment with PVC..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 1
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
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-storage
        persistentVolumeClaim:
          claimName: nginx-pvc
EOF

# Wait for pod with PVC
wait_for_pod

# Get pod name
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo -e "\nPod with PVC name: $POD_NAME"

# Create file in pod with PVC
echo -e "\n#### Creating file in pod with PVC..."
kubectl exec -it $POD_NAME -- bash -c 'echo "hello, king memo..god bless you" > /usr/share/nginx/html/hello.txt'

# Test file access
echo -e "\n#### Testing file access..."
kubectl exec -it $POD_NAME -- curl localhost/hello.txt

# Delete pod
echo -e "\n#### Deleting pod..."
kubectl delete pod $POD_NAME

# Wait for new pod
wait_for_pod

# Get new pod name
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo -e "\nNew pod name: $POD_NAME"

# Verify file persists
echo -e "\n#### Verifying file persists in new pod..."
kubectl exec -it $POD_NAME -- curl localhost/hello.txt

echo -e "\n#### Demonstration complete!"

#Delete my-deployment, nginx-pvc
echo -e "\n#### Deleting deployment and PVC..."
kubectl delete deployment my-deployment
kubectl delete pvc nginx-pvc
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
