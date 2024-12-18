# Lab 31: Network Configuration
Build a new image from Dockerfile in https://github.com/IbrahimmAdel/static-website.git  
Create a deployment using this image  
Create a service to expose the deployment.  
Define a network policy that allow traffic to the NGINX pods only from other pods within the same namespace.  
Enable the NGINX Ingress controller using Minikube addons.  
Create an Ingress resource.  
Update /etc/hosts to map the domain to the Minikube IP address.   
Access the custom NGINX service via the Ingress endpoint using the domain name.  

---

**Ingress**  

consolidate your routing rules into a single resource as it
can expose multiple services under the same IP address

- Configure multiple paths for same host
- Configure multiple sub-domains or domains
- Configure TLS Certificate - https://

**Ingress Controller**

- Evaluates all the rules
- Manages redirections
- Entry point to the cluster
- Many third-party implementations
- K8s Nginx Ingress Controller

**NetworkPolicies** 
- handle pod-to-pod communication rules at the network level.
- are enforced by the Container Network Interface (CNI) plugin in your Kubernetes cluster.

---


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

----

## For Testing
```bash
# test ingress host
curl http://myapp.local

# test network Policy
# 1- Create a test pod in the same namespace
kubectl run test-pod-same-ns --image=busybox --rm -it -- /bin/sh

# Test access from the same namespace: Inside the test-pod-same-ns, run
wget -O- --timeout=2 http://myapp.local     #should success  

# 2- Create a test pod in a different namespace
kubectl create namespace test-namespace
kubectl run test-pod-diff-ns -n test-namespace --image=busybox --rm -it -- /bin/sh

# Test access from a different namespace
wget -O- --timeout=2 http://myapp.local    #should fail

```

---

## For troubleshooting
```bash
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

