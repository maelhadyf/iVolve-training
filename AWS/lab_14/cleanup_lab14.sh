#!/bin/bash

# Set AWS region
export AWS_DEFAULT_REGION="us-east-1"

echo "Starting cleanup of all resources containing 'memo-lab14'..."

# Function to wait for ALB deletion
wait_for_alb_deletion() {
    local alb_arn=$1
    echo "Waiting for ALB deletion..."
    while aws elbv2 describe-load-balancers --load-balancer-arns $alb_arn 2>/dev/null; do
        echo "ALB is still being deleted..."
        sleep 10
    done
    echo "ALB deleted successfully"
}

# Delete Load Balancer
echo "Finding and deleting Load Balancer..."
ALB_ARN=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `memo-lab14`)].LoadBalancerArn' --output text)
if [ ! -z "$ALB_ARN" ] && [ "$ALB_ARN" != "None" ]; then
    echo "Deleting Load Balancer: $ALB_ARN"
    aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
    wait_for_alb_deletion $ALB_ARN
fi

# Delete Target Groups
echo "Finding and deleting Target Groups..."
TG_ARNS=$(aws elbv2 describe-target-groups --query 'TargetGroups[?contains(TargetGroupName, `memo-lab14`)].TargetGroupArn' --output text)
if [ ! -z "$TG_ARNS" ]; then
    for TG_ARN in $TG_ARNS; do
        echo "Deleting Target Group: $TG_ARN"
        aws elbv2 delete-target-group --target-group-arn $TG_ARN
    done
fi

# Find VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*memo-lab14*" --query 'Vpcs[0].VpcId' --output text)

if [ ! -z "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
    echo "Found VPC: $VPC_ID"

    # Terminate EC2 instances in the VPC
    echo "Terminating EC2 instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)
    if [ ! -z "$INSTANCE_IDS" ]; then
        aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
        echo "Waiting for instances to terminate..."
        aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    fi

    # Delete Security Groups
    echo "Deleting Security Groups..."
    SG_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=*memo-lab14*" \
        --query 'SecurityGroups[].GroupId' \
        --output text)
    for SG_ID in $SG_IDS; do
        echo "Deleting Security Group: $SG_ID"
        aws ec2 delete-security-group --group-id $SG_ID
    done

    # Detach and delete Internet Gateway
    echo "Deleting Internet Gateway..."
    IGW_ID=$(aws ec2 describe-internet-gateways \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[0].InternetGatewayId' \
        --output text)
    if [ ! -z "$IGW_ID" ] && [ "$IGW_ID" != "None" ]; then
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
    fi

    # Delete Subnets
    echo "Deleting Subnets..."
    SUBNET_IDS=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[].SubnetId' \
        --output text)
    for SUBNET_ID in $SUBNET_IDS; do
        echo "Deleting Subnet: $SUBNET_ID"
        aws ec2 delete-subnet --subnet-id $SUBNET_ID
    done

    # Delete Route Tables
    echo "Deleting Route Tables..."
    RT_IDS=$(aws ec2 describe-route-tables \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' \
        --output text)
    for RT_ID in $RT_IDS; do
        echo "Deleting Route Table: $RT_ID"
        aws ec2 delete-route-table --route-table-id $RT_ID
    done

    # Delete VPC
    echo "Deleting VPC..."
    aws ec2 delete-vpc --vpc-id $VPC_ID
fi

echo "Cleanup completed!"
