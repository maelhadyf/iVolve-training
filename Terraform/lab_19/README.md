# 🚀 Remote Backend and LifeCycles Rules

Using terraform: create s3, dynamodb_table as backend , lifecycle rule prevent_destroy
also create vpc with public subnet, and ec2 with security group that when changing,
 apply lifecycle rules, also use cloudwatch, SNS to notify email: 
create_before_destroy = true
ignore_changes        = [tags]
replace_triggered_by  = [aws_security_group.example.id]

---

# Lifecycle Rules
## 1. create_before_destroy:
- Creates new resource before destroying the old one
- Useful for zero-downtime deployments
- Perfect for web servers behind load balancers
- Helps maintain service availability

## 2. prevent_destroy:
- Prevents accidental deletion of critical resources
- Adds safety for production databases, storage, etc.
- Will raise an error if destruction is attempted
- Must be removed if resource actually needs deletion

## 3. ignore_changes:
- Ignores specified attributes during updates
- Useful when external systems modify resources
- Can ignore single or multiple attributes
- Common for auto-scaling groups or resources modified outside Terraform

## 4. replace_triggered_by:
- Forces resource replacement when referenced attributes change
- Useful for dependent resources that need recreation
- Helps maintain resource consistency
---

## 📋 Overview
This project sets up a complete AWS infrastructure using Terraform, including VPC, EC2, and state management.

## 🏗️ Infrastructure Components
- 🪣 S3 Bucket (Remote State Storage)
- 🔒 DynamoDB Table (State Locking)
- 🌐 VPC with Public Subnet
- 🖥️ EC2 Instance (Amazon Linux 2023)
- 🛡️ Security Group
- 📊 CloudWatch Components
- 📧 SNS Components
- ⚡ CloudWatch Alarms

## 🔧 Prerequisites
- AWS CLI configured
- Terraform installed
- AWS credentials with appropriate permissions

## 📁 Project Structure
```
memo-lab19/
├── variables.tf         # Variable definitions
├── provider.tf         # AWS provider config
├── backend.tf         # State backend config
├── backend-resources.tf # S3 and DynamoDB
├── locals.tf          # Local variables
├── network.tf         # VPC components
├── security.tf        # Security groups
├── ec2.tf            # EC2 instance
├── monitoring.tf      # CloudWatch & SNS
├── outputs.tf        # Output definitions
└── terraform.tfvars  # Variable values
```

---

## 🚀 Deployment Instructions
1. Clone the repository
2. Initialize Terraform
```bash
terraform init
```
3. Configure Variables `terraform.tfvars`
```bash
# Edit terraform.tfvars
project_name = "your-project"
environment  = "dev"
alert_email  = "your-email@example.com"
```

4. Review the plan
```bash
terraform plan
```
5. Apply the configuration
```bash
terraform apply
```
After successful creation of the backend resources:

6. Uncomment the backend configuration in `backend.tf`
7. Run:
```bash
terraform init -migrate-state
```

---

## 🧪 Testing lifecycle rules applied to the EC2 instance:

### 1. Testing create_before_destroy:
```hcl
# In ec2.tf, make a change that triggers replacement, like changing instance_type
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"  # Change from t2.micro to t3.micro
  # ... rest of configuration ...
}
```
```bash
# Run terraform plan to see the change
terraform plan
```
You should see output indicating that a new instance will be created before the old one is destroyed.

### 2. Testing ignore_changes = [tags["Environment"]]:
```bash
# First, apply your configuration
terraform apply

# Then, manually add or modify tags in AWS Console
# Go to EC2 Dashboard -> Select your instance -> Tags -> Add/Edit tags
# Add a new tag like "Environment = "testing"

# Run terraform plan again
terraform plan
```
You should see no changes in the plan, despite the manual tag modifications.

### 3. Testing replace_triggered_by = [aws_security_group.example.ingress]:
```hcl
# In security.tf, modify the security group
resource "aws_security_group" "example" {
  # ... existing configuration ...

  # Add a new ingress rule
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
```bash
terraform plan
```
You should see that the EC2 instance will be replaced because of the security group change.

---

## 🧹 Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

---

## ⚙️ Features

- 🔄 Remote State Management
- 🔒 State Locking with DynamoDB
- 🏗️ Create Before Destroy Strategy
- 🏷️ Tag Change Ignorance
- 🔄 Auto-replacement on Security Group Changes

---

## 🛡️ Security Features

- 🔐 Encrypted State Storage
- 🌐 VPC Isolation
- 🚪 Limited Security Group Access
- 🔒 DynamoDB State Locking

---

## 📤 Outputs

- 🆔 Instance ID
- 🌐 Public IP Address
- 🔑 Security Group ID

---

## 🔄 Lifecycle Rules

- ✨ Create Before Destroy
- 🏷️ Ignore Tag Changes
- 🔄 Replace on Security Group Changes

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
