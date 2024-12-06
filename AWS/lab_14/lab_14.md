# create VPC with 2 public subnets, launch 2 EC2s with Nginx and Apache installed using user data, create and configure a Load Balancer to access the 2 Web servers.

## Overview
This script automates the deployment of a highly available web infrastructure on AWS, featuring load-balanced Nginx and Apache web servers across multiple availability zones.

---

### Components
- VPC with 2 public subnets across different AZs
- Internet Gateway for public internet access
- Application Load Balancer
- 2 EC2 instances (Nginx and Apache)
- Security Groups for ALB and EC2 instances

---

## Prerequisites
- AWS CLI installed and configured
- Appropriate AWS credentials with necessary permissions
- Bash shell environment

---

## Quick Start
Download the script `setup_lab14.sh`
```bash
#Make the script executable
chmod +x setup_lab14.sh

#Run the script
./setup_lab14.sh
```

---

## Cleanup
To remove all created resources:
```bash
#Make the script executable
chmod +x cleanup_lab14.sh

#Run the script
./cleanup_lab14.sh
```

---

## Configuration
Default settings in the script:
- Region: us-east-1
- VPC CIDR: 10.0.0.0/16
- Subnet CIDRs: 10.0.1.0/24, 10.0.2.0/24
- Instance Type: t2.micro
- AMI: Ubuntu (ami-0c7217cdde317cfec)

---

## Features
High Availability : Deploys across two availability zones

Load Balancing : Distributes traffic between Nginx and Apache servers

Security : Implements security groups with principle of least privilege

Automation : Complete infrastructure deployment in a single script

---

## Resource Details
### VPC and Networking
- VPC with DNS support enabled
- Two public subnets in different AZs
- Internet Gateway for public access
- Route table for internet access

### Security
- **ALB Security Group**:
  - Allows inbound HTTP (80)

- **EC2 Security Group**:
  - Allows inbound HTTP from ALB
  - Allows inbound SSH (22) for management

### Web Servers
- **Nginx Server**:
  - Ubuntu-based EC2 instance
  - Displays "Welcome King Memo Nginx"

- **Apache Server**:
  - Ubuntu-based EC2 instance
  - Displays "Welcome King Memo Apache"

---

## Monitoring
- **ALB health checks monitor instance health**
- **Default health check settings:**
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy threshold: 2
  - Unhealthy threshold: 2

---

## Troubleshooting
### 1. 502 Bad Gateway :
- Wait 2-3 minutes for instances to initialize
- Check security group configurations
- Verify web server status on instances
### Instance Access :
- SSH using the key pair specified
- Check instance security group rules

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
