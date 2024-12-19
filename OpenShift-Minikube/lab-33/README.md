# Lab 33: Multi-container Applications  

Create a deployment for Jenkins with an init container that sleeps for 10 seconds before the Jenkins container starts.  
Use readiness and liveness probes.  
Create a NodePort service to expose Jenkins.   
Verify that the init container runs successfully and Jenkins is properly initialized.   
What is the differnet between  readiness & liveness , init & sidecar container.  

---

## Readiness vs Liveness Probes

### Readiness:
- Checks if the pod is **READY** to serve traffic
- **Failed probe** = Remove from load balancer
- Pod stays alive but gets **no traffic**

### Liveness:
- Checks if the pod is **ALIVE** and healthy
- **Failed probe** = Pod gets restarted
- Used to recover from **deadlocks**

---

## Init vs Sidecar Containers

### Init Containers:
1. Run **before** the main app starts
2. Run **sequentially** and must complete
3. Die after completion
4. **Use case**: Setup, wait for dependencies

### Sidecar Containers:
2. Run **alongside** the main app
3. Run for the **entire pod lifetime**
4. Keep running with the main container
5. **Use case**: Logging, monitoring, proxies

---

## 🏃‍♂️ Running
```bash
kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-service.yaml
```

---

## 🧪 Testing
```bash
# Check the status of the pods
kubectl get pods

# View the details of the Jenkins pod
# In the output of the describe command, look for the "Events" section. You should see that the init container
kubectl describe pod <jenkins-pod-name>

# to get the URL
minikube service jenkins --url
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!

