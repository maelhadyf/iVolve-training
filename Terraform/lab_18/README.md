# 🚀 Terraform Modules

Create VPC with 2 public subnets in main.tf file. 
Create EC2 module to create 1 EC2 with Nginx installed on it using user data. 
Use this module to deploy 1 EC2 in each subnet. 

---

## 🌐 Infrastructure Overview

- 1 VPC with 2 public subnets
- 2 EC2 instances running Nginx
- Custom web page displaying instance information
- Security groups with HTTP and SSH access

---

## ✅ Prerequisites

- AWS Account
- Terraform installed
- AWS CLI configured
- Existing SSH key pair in AWS

---

## 📁 Project Structure
terraform-project/
├── main.tf
├── modules/
│ └── ec2/
│  ├── main.tf
│  └── variables.tf
└── lab_18.md

---

## 🛠️ Resources Created

### 🌍 Networking
- VPC (CIDR: 10.0.0.0/16)
- 2 Public Subnets
- Internet Gateway
- Route Table

### 💻 Compute
- 2 EC2 instances (Amazon Linux 2023)
- Nginx web server
- Custom webpage

### 🔒 Security
- Security Groups
  - HTTP (80)
  - SSH (22)
- Public subnets with internet access

---

## 🚀 Usage

1. Clone the repository
2. Initialize Terraform
```bash
terraform init
```
3. Review the plan
```bash
terraform plan
```
4. Apply the configuration
```bash
terraform apply
```

---

## 🧹 Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

---

✨ Web Page Features
The Nginx web page displays:

- Server's Public IP
- Server's Public DNS
- Custom welcome message

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
