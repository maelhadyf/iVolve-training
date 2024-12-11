# 🚀 Create a VPC with public and private subnets and 1 EC2 in each subnet, configure private EC2 security group to only allow inbound SSH from public EC2 IP, SSH to the private instance using bastion host.

This project automates the creation of a secure bastion host architecture in AWS, enabling secure access to private instances.

## 🛠️ Features

- ✨ VPC with public and private subnets
- 🔒 Secure bastion host configuration
- 🖥️ Private EC2 instance
- 🛡️ Security groups with minimal access
- 🌐 Internet Gateway for public access

## 🚦 Prerequisites

- AWS CLI installed and configured
- AWS account with appropriate permissions
- Key pair named "ubuntu" (or modify KEY_NAME in script)

## 🏃‍♂️ Quick Start
### 1. Download the script `setup_lab13.sh`
```bash
#Make the script executable
chmod +x setup_lab13.sh

#Run the script
./setup_lab13.sh
```
### 2. Connect to Private Instance
```bash
# Copy your key to bastion host
scp -i ubuntu.pem ubuntu.pem ubuntu@<BASTION_IP>:~/.ssh/

# SSH to bastion host
ssh -i ubuntu.pem ec2-user@<BASTION_IP>

# From bastion, SSH to private instance
chmod 400 ~/.ssh/ubuntu.pem
ssh -i ~/.ssh/ubuntu.pem ubuntu@<PRIVATE_IP>
```

---

## Cleanup
To remove all created resources:
```bash
#Make the script executable
chmod +x cleanup_lab13.sh

#Run the script
./cleanup_lab13.sh
```

---

## 🔐 Security Features

The script implements the following security features:

- ✅ **Bastion host in public subnet**
- ✅ **Private instance in private subnet**
- ✅ **SSH access to bastion host from anywhere**
- ✅ **SSH access to private instance only from bastion host**
- ✅ **No direct internet access to private instance**

## ⚠️ Important Notes

- Remember to **delete resources** when not in use to avoid charges.
- Keep your **private key secure**.
- Never **commit AWS credentials** to version control.
- Modify **security group rules** according to your needs.

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
