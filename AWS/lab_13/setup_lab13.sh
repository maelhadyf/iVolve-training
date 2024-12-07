#!/bin/bash

echo "Setting variables..."
# Set variables
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
REGION="us-east-1"
AZ="${REGION}a"
AMI_ID="ami-0c7217cdde317cfec"  # Ubuntu AMI
KEY_NAME="ubuntu"        # Replace with your key pair name

echo "Creating VPC..."
# Create VPC and capture VPC ID
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --query 'Vpc.VpcId' \
    --output text \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=memo-lab13-vpc}]')

echo "Enabling DNS hostname support..."
# Enable DNS hostname support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

echo "Creating Internet Gateway..."
# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=memo-lab13-igw}]')
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

echo "Creating subnets..."
# Create subnets
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_SUBNET_CIDR \
    --availability-zone $AZ \
    --query 'Subnet.SubnetId' \
    --output text \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=memo-lab13-public-subnet}]')

PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PRIVATE_SUBNET_CIDR \
    --availability-zone $AZ \
    --query 'Subnet.SubnetId' \
    --output text \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=memo-lab13-private-subnet}]')

echo "Creating and configuring route tables..."
# Create and configure route tables
PUBLIC_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=memo-lab13-public-rt}]')
aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $PUBLIC_SUBNET_ID

echo "Enabling auto-assign public IP for public subnet..."
# Enable auto-assign public IP for public subnet
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_ID --map-public-ip-on-launch

echo "Creating security groups..."
# Create security groups
BASTION_SG_ID=$(aws ec2 create-security-group \
    --group-name "memo-lab13-bastion-sg" \
    --description "Bastion Host Security Group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=memo-lab13-bastion-sg}]')

PRIVATE_SG_ID=$(aws ec2 create-security-group \
    --group-name "memo-lab13-private-sg" \
    --description "Private Instance Security Group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=memo-lab13-private-sg}]')

echo "Configuring security group rules..."
# Configure security group rules
aws ec2 authorize-security-group-ingress \
    --group-id $BASTION_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol tcp \
    --port 22 \
    --source-group $BASTION_SG_ID

echo "Launching EC2 instances..."
# Launch EC2 instances
BASTION_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PUBLIC_SUBNET_ID \
    --security-group-ids $BASTION_SG_ID \
    --query 'Instances[0].InstanceId' \
    --output text \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=memo-lab13-bastion}]')

PRIVATE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PRIVATE_SUBNET_ID \
    --security-group-ids $PRIVATE_SG_ID \
    --query 'Instances[0].InstanceId' \
    --output text \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=memo-lab13-private}]')

echo "Waiting for instances to be running..."
# Wait for instances to be running
aws ec2 wait instance-running --instance-ids $BASTION_ID $PRIVATE_ID

echo "Getting instance details..."
# Get instance details
BASTION_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $BASTION_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

PRIVATE_IP=$(aws ec2 describe-instances \
    --instance-ids $PRIVATE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

echo "Printing connection information..."
# Print connection information
echo "Setup completed!"
echo "Bastion Host Public IP: $BASTION_PUBLIC_IP"
echo "Private Instance IP: $PRIVATE_IP"
echo ""
echo "To connect to the private instance:"
echo "1. Copy your key to bastion host:"
echo "   scp -i $KEY_NAME.pem $KEY_NAME.pem ubuntu@$BASTION_PUBLIC_IP:~/.ssh/"
echo ""
echo "2. SSH to bastion host:"
echo "   ssh -i $KEY_NAME.pem ec2-user@$BASTION_PUBLIC_IP"
echo ""
echo "3. From bastion, SSH to private instance:"
echo "   chmod 400 ~/.ssh/$KEY_NAME.pem"
echo "   ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PRIVATE_IP"
