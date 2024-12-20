

---

## Comparison between Deployment and StatefulSet

### Pod Identity and Ordering
- **Deployment**: Pods are interchangeable with random names.
- **StatefulSet**: Pods have unique, persistent identities and ordered names (e.g., pod-0, pod-1, etc.).

### Storage
- **Deployment**: Usually uses temporary storage.
- **StatefulSet**: Can use persistent storage with stable storage identifiers.

### Scaling
- **Deployment**: Random scaling, with all pods being identical.
- **StatefulSet**: Ordered scaling (0->N), where each pod can be unique.

### Updates
- **Deployment**: Simultaneous updates are possible.
- **StatefulSet**: Ordered updates, one at a time, from the highest to lowest ordinal.

### Use Cases
- **Deployment**: Best suited for stateless applications (e.g., web servers, API services).
- **StatefulSet**: Best suited for stateful applications (e.g., databases, distributed systems).

> **Note:**  
> In a StatefulSet, typically the Pod with ordinal 0 (the first Pod) is designated as the master/primary.  
> This is a common pattern in distributed systems, particularly databases.

---

## 🏃‍♂️ Running
```bash
# edit pass in mysql-secret.yaml
echo -n 'yourpassword' | base64    

# apply all resources in current dir
kubectl apply -f .
```

---

## 🧪 Testing
```bash
# retrieve info about all the resources in the current namespace
kubectl get all
```

---

## 🧹 Cleanup
```bash
# delete all resources in current dir
kubectl delete -f .
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
