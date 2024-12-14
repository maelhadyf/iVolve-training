
Implement the below diagram with Terraform using variables for all arguments.
do not repeat code.
Install Nginx using user_data, Apache on public ec2 using remote provisioner.
Create the VPC manually then make terraform manage it ‘Terraform import’.
Output public ip and private ip of EC2s.

---
- Create the VPC manually and capture its ID
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

- Import the existing VPC into Terraform state using the VPC ID:
```bash
terraform import aws_vpc.imported_vpc < your-vpc-id >
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
