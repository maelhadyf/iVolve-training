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

