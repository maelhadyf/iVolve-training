
Implement the below diagram with Terraform using variables for all arguments.
do not repeat code.
Install Nginx using user_data, Apache on public ec2 using remote provisioner.
Create the VPC manually then make terraform manage it ‘Terraform import’.
Output public ip and private ip of EC2s.

---
### 1- clone this project
### 2- Create the VPC manually and capture its ID
```bash
# Create VPC and capture its ID
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=terraform-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text \
    --region us-east-1)

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames "{\"Value\":true}" \
    --region us-east-1

# Enable DNS support
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-support "{\"Value\":true}" \
    --region us-east-1

# Print the VPC ID
echo "VPC ID: $VPC_ID"
```
### 3. Initialize Terraform
```bash
terraform init
```
### 4- Edit `terraform.tfvars` file
```hcl
vpc_id       = "vpc-002c3133857d32efb"    # Replace with your manually created VPC ID
ssh_key_name = "amazon"   # Replace with your key name
```
### 5- Import the existing VPC into Terraform state using the VPC ID
```bash
terraform import aws_vpc.imported_vpc < your-vpc-id >
```
### 6. Review the plan
```bash
terraform plan
```
### 7. Apply the configuration
```bash
terraform apply
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
