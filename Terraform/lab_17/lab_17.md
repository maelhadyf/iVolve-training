# Multi-Tier Application Deployment with Terraform

- Create ‘ivolve’ VPC manually in AWS and use Data block to get VPC id in your configuration file. 
- Use Terraform to define and deploy a multi-tier architecture including 2 subnets, EC2, and RDS database. 
- Use local provisioner to write the EC2 IP in a file called ec2-ip.txt.

![asdf](https://github.com/user-attachments/assets/8ce0f6d4-9649-4755-81e5-2839cacd7207)

This is the most common and fundamental pattern, consisting of:

### Presentation Tier (Frontend)
- Handles user interface
- Examples: Web pages, mobile app UIs
- AWS Services: Amazon S3, CloudFront, Cognito

### Logic/Application Tier (Backend)
- Processes business logic and user actions
- Handles data processing and application functionality
- AWS Services: API Gateway, Lambda, EC2, ECS

### Data Tier
- Manages data storage and retrieval
- AWS Services: RDS, DynamoDB, S3

---

## 📋 Project Overview
This project provisions a complete AWS infrastructure using **Terraform**, including VPC, EC2, and RDS instances, to create a secure and scalable architecture.

---

## 🏗️ Infrastructure Components

- **🔸 VPC** with public and private subnets
- **🖥️ EC2 instance** in the public subnet
- **🗄️ RDS MySQL database** in the private subnet
- **🛡️ Security Groups** for EC2 and RDS
- **🌍 Internet Gateway** and **Route Tables**
- **🔌 Network configurations** (including subnets, security rules, and routing)

---

## 🚀 Prerequisites

To run this project, ensure the following:

- **AWS CLI** is installed and configured
- **Terraform** is installed
- **AWS access credentials** set up (either via environment variables or AWS profile)
- **SSH key pair** named `"jenkins"` for EC2 instance access

---

## 📁 Project Structure
```
.
├── main.tf          # Main infrastructure configuration
├── variables.tf     # Variable declarations
├── terraform.tfvars # Variable values
└── lab_17.md       # This README file
```

---

## 🔧 Configuration

The infrastructure includes:

- **Region**: us-east-1
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24 (us-east-1a)
- **Private Subnet**: 10.0.2.0/24 (us-east-1b)
- **EC2**: t2.micro with Amazon Linux 2
- **RDS**: MySQL 8.0 on db.t3.micro

---

## 🔒 Security Features

- EC2 instance in the public subnet with restricted SSH access
- RDS instance in the private subnet
- Security groups with minimal required access
- Database credentials managed through variables

---

## 🚀 Deployment Instructions

1. Clone the repository
2. Update `terraform.tfvars`
```hcl
db_username = "your_username"
db_password = "your_secure_password"
```
3. Initialize Terraform
```bash
terraform init
```
4. Review the plan
```bash
terraform plan
```
5. Apply the configuration
```bash
terraform apply
```

---

## 🧪 Testing

1. SSH into EC2 instance (replace with your key path)
```bash
ssh -i /path/to/your/key.pem ec2-user@$(cat ec2-ip.txt)

# Once connected, test internet connectivity
ping 8.8.8.8
```
2. Install MySQL client on EC2 using the following commands
```bash
sudo su -
dnf -y localinstall https://dev.mysql.com/get/mysql80-community-release-el9-4.noarch.rpm
dnf -y install mysql mysql-community-client
```
3. Verify MySQL client installation:
```bash
mysql --version
```

4. Now you can test the connection to your RDS instance:
```bash
mysql -h <rds-endpoint> -P 3306 -u admin -p    # remove 3306 from <rds-endpoint>
```

---

## 🧹 Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

---

## 📊 Outputs

After successful deployment, you'll receive:

- **EC2 instance public IP**
- **RDS endpoint**

---

## ⚠️ Important Notes

- Remember to change default database credentials
- Store sensitive information securely
- Review security group rules before production use
- Always backup your database before making changes

---

## ✨ Best Practices

- For better security, you can integrate with **AWS Secrets Manager** or **AWS Systems Manager Parameter Store**.
- Keep credentials secure and never commit them to version control
-  Create a `.gitignore` file to prevent sensitive files from being committed:
  ```
# .gitignore
*.tfvars
*.tfvars.json
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
  ```
- Use private subnets for databases
- Regularly update security group rules
- Monitor your resources
- Use tags for better resource management

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
