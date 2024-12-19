# Lab 32: Configuring a MySQL Pod using ConfigMap and Secret

Create a namespace called ivolve and Apply resource quota to limit resource usage within the namespace.   
Create a Deployment in ivolve namespace for MySQL with resources requests: CPU: 0.5 vcpu, Mem: 1G, and resources limits: CPU: 1 vcpu, Mem: 2G.  
Define MySQL database name and user in a ConfigMap.   
Store the MySQL root password and user password in a Secret.  
Exec into the MySQL pod and verify the Database configurations.  


---

## 🏃‍♂️ Running
```bash
# Apply the configurations
kubectl apply -f namespace-quota.yaml
kubectl apply -f mysql-configmap.yaml
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-deployment.yaml
```

---

## 🧪 Testing
```bash
# 1- Check if the pod is running:
kubectl get pods -n ivolve

# 2- Once the pod is running, exec into it:
# Replace mysql-pod-name with actual pod name
kubectl exec -it <mysql-pod-name> -n ivolve -- mysql -uroot -p

# 3- When prompted, enter the root password ('rootpassword')

# 4- Verify the database configuration:
SHOW DATABASES;
SELECT User FROM mysql.user;

# 5- To check the resource quota usage:
kubectl describe resourcequota ivolve-quota -n ivolve    # This will show you how much of the quota is being used by the MySQL deployment.
```

---

## 🧹 Cleanup
```bash
kubectl delete namespace ivolve
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!

