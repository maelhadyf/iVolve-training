# Lab 35: Helm Chart Deployment

Create a new Helm chart for Nginx. Deploy the Helm chart and verify the deployment.  
Access the Nginx server.  
Delete nginx release.  

---

## Helm - Package Manager

Helm is the package manager for Kubernetes. Think of it like apt/yum for Kubernetes

---

## Helm installation
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
rm get_helm.sh
```

## 🏃‍♂️ Running
```bash
# 1- create a new Helm chart
helm create nginx-chart

# 2- Navigate to the chart directory and modify the values.yaml file:
cd nginx-chart
nano values.yaml    # make  tag: "stable" , and save
```
change only tag, service type
```yaml
image:
  repository: nginx
  tag: "stable"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer  # Changed to LoadBalancer for easy access
  port: 80
```

```bash
# 3- Deploy the Helm chart
helm install my-nginx .

# 4- Access the Nginx server            If using Minikube, use this command instead:
minikube service my-nginx-nginx-chart
curl <url> 
```

---

## 🧪 Testing
```bash
# Check the release status
helm list

# Check the pods
kubectl get pods

# Check the service
kubectl get svc
```

---

## 🧹 Cleanup
```bash
# Delete the Nginx release:
helm uninstall my-nginx
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
