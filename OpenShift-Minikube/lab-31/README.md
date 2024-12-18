

## 1- Build the Docker image with your Dockerfile:
```bash
docker build -t custom-nginx:latest .
```

## 2- To use local image Not pull from outside
1- Using Minikube's Docker daemon (Recommended Approach):
```bash
# Save your local image to a tar file
docker save custom-nginx:latest > custom-nginx.tar

# Load it into Minikube's Docker daemon
eval $(minikube docker-env)
docker load < custom-nginx.tar
```

2- Start a local registry in Minikube:
```bash
# Start a local registry in Minikube
minikube addons enable registry

# Tag and push your image to the local registry
docker tag custom-nginx:latest localhost:5000/custom-nginx:latest
docker push localhost:5000/custom-nginx:latest
```
Update the deployment to use the registry image:
```yaml
image: localhost:5000/custom-nginx:latest
```

## 3- Enable Nginx Ingress Controller in Minikube:
```bash
minikube addons enable ingress
```

## 4- Apply all the configurations:
```bash
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-network-policy.yaml
kubectl apply -f nginx-ingress.yaml
```

## 5- Update `/etc/hosts` (you'll need sudo privileges):
```bash
# Add this line to /etc/hosts (replace <MINIKUBE_IP> with actual IP)
sudo nano /etc/hosts

# add this line
<MINIKUBE_IP> myapp.local
```

## 6- Verification
```bash
curl http://myapp.local

#get services
kubectl get svc
kubectl get ingress

# Get the Ingress controller IP
kubectl get ingress nginx-ingress

# Check if the image is available in Minikube's Docker daemon
eval $(minikube docker-env)
docker images | grep custom-nginx

# Check pod status
kubectl get pods

# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!

