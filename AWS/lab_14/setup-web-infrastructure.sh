#!/bin/bash

# Set AWS region
export AWS_DEFAULT_REGION="us-east-1"

# Define variables
VPC_CIDR="10.0.0.0/16"
SUBNET1_CIDR="10.0.1.0/24"
SUBNET2_CIDR="10.0.2.0/24"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c7217cdde317cfec"  # Ubuntu AMI

# Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=memo-lab14}]' \
    --query 'Vpc.VpcId' \
    --output text)

# Enable DNS hostname support for VPC
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

# Create Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=memo-lab14}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create public subnets in different AZs
echo "Creating public subnets..."
SUBNET1_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $SUBNET1_CIDR \
    --availability-zone ${AWS_DEFAULT_REGION}a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=memo-lab14-subnet1}]' \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET2_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $SUBNET2_CIDR \
    --availability-zone ${AWS_DEFAULT_REGION}b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=memo-lab14-subnet2}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Enable auto-assign public IP for subnets
aws ec2 modify-subnet-attribute --subnet-id $SUBNET1_ID --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $SUBNET2_ID --map-public-ip-on-launch

# Create route table
echo "Creating route table..."
RTB_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=memo-lab14-rtb}]' \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Create route to Internet Gateway
aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Associate route table with subnets
aws ec2 associate-route-table --subnet-id $SUBNET1_ID --route-table-id $RTB_ID
aws ec2 associate-route-table --subnet-id $SUBNET2_ID --route-table-id $RTB_ID

# Create security group for ALB
echo "Creating ALB security group..."
ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name memo-lab14-alb-sg \
    --description "Security group for ALB" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Add ALB security group rules
aws ec2 authorize-security-group-ingress --group-id $ALB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0

# Create security group for EC2 instances
echo "Creating EC2 security group..."
EC2_SG_ID=$(aws ec2 create-security-group \
    --group-name memo-lab14-ec2-sg \
    --description "Security group for web servers" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Add EC2 security group rules
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 80 --source-group $ALB_SG_ID
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Create Nginx user data script
NGINX_USER_DATA=$(cat <<'EOF'
#!/bin/bash
# Update package list
apt-get update

# Install Nginx (with automatic yes to prompts)
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

# Create index.html with content
echo "Welcome King Memo Nginx" > /var/www/html/index.html

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx
EOF
)

# Create Apache user data script
APACHE_USER_DATA=$(cat <<'EOF'
#!/bin/bash
# Update package list
apt-get update

# Install Apache (with automatic yes to prompts)
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

# Create index.html with content
echo "Welcome King Memo Apache" > /var/www/html/index.html

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start and enable Apache
systemctl start apache2
systemctl enable apache2
EOF
)

# Launch EC2 instances
echo "Launching EC2 instances..."
NGINX_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $SUBNET1_ID \
    --security-group-ids $EC2_SG_ID \
    --user-data "$NGINX_USER_DATA" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=memo-lab14-nginx}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

APACHE_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $SUBNET2_ID \
    --security-group-ids $EC2_SG_ID \
    --user-data "$APACHE_USER_DATA" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=memo-lab14-apache}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

# Wait for instances to be running
echo "Waiting for instances to be running..."
aws ec2 wait instance-running --instance-ids $NGINX_INSTANCE_ID $APACHE_INSTANCE_ID

# Add additional wait time for services to initialize
echo "Waiting for services to initialize..."
sleep 90

# Create target group with better health check settings
echo "Creating target group..."
TG_ARN=$(aws elbv2 create-target-group \
    --name memo-lab14-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-protocol HTTP \
    --health-check-path / \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 2 \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

# Register targets
aws elbv2 register-targets \
    --target-group-arn $TG_ARN \
    --targets Id=$NGINX_INSTANCE_ID Id=$APACHE_INSTANCE_ID

# Create Application Load Balancer
echo "Creating Application Load Balancer..."
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name memo-lab14-alb \
    --subnets $SUBNET1_ID $SUBNET2_ID \
    --security-groups $ALB_SG_ID \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

# Wait for ALB to be active
echo "Waiting for ALB to be active..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ALB_ARN

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN

# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "Setup complete!"
echo "ALB DNS name: $ALB_DNS"
echo "Please wait 2-3 minutes for the instances to fully initialize before accessing the ALB DNS name."

# Print target health status after a brief wait
echo "Waiting to check target health status..."
sleep 30
aws elbv2 describe-target-health --target-group-arn $TG_ARN
