




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


