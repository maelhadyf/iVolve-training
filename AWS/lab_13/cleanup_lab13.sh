#!/bin/bash

REGION="us-east-1"

echo "Starting cleanup of memo-lab13 resources..."

# Get instance IDs and terminate them
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=memo-lab13*" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text)

if [ ! -z "$INSTANCE_IDS" ]; then
    echo "Terminating EC2 instances..."
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
fi

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=memo-lab13*" \
    --query 'Vpcs[].VpcId' \
    --output text)

if [ ! -z "$VPC_ID" ]; then
    # Delete VPC endpoints
    echo "Deleting VPC endpoints..."
    ENDPOINT_IDS=$(aws ec2 describe-vpc-endpoints \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'VpcEndpoints[].VpcEndpointId' \
        --output text)
    for endpoint in $ENDPOINT_IDS; do
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $endpoint
    done

    # Delete network interfaces
    echo "Deleting network interfaces..."
    ENI_IDS=$(aws ec2 describe-network-interfaces \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'NetworkInterfaces[].NetworkInterfaceId' \
        --output text)
    for eni in $ENI_IDS; do
        aws ec2 delete-network-interface --network-interface-id $eni
    done

    # Delete security groups (except default)
    echo "Deleting security groups..."
    SG_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=memo-lab13*" \
        --query 'SecurityGroups[].GroupId' \
        --output text)
    for sg in $SG_IDS; do
        aws ec2 delete-security-group --group-id $sg || true
    done

    # Delete route table associations and route tables
    echo "Deleting route tables..."
    RT_IDS=$(aws ec2 describe-route-tables \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=memo-lab13*" \
        --query 'RouteTables[].RouteTableId' \
        --output text)
    
    for rt in $RT_IDS; do
        # Delete route table associations
        ASSOC_IDS=$(aws ec2 describe-route-tables \
            --route-table-ids $rt \
            --query 'RouteTables[].Associations[].RouteTableAssociationId' \
            --output text)
        for assoc in $ASSOC_IDS; do
            aws ec2 disassociate-route-table --association-id $assoc
        done
        aws ec2 delete-route-table --route-table-id $rt
    done

    # Detach and delete internet gateway
    echo "Deleting internet gateway..."
    IGW_ID=$(aws ec2 describe-internet-gateways \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[].InternetGatewayId' \
        --output text)
    if [ ! -z "$IGW_ID" ]; then
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
    fi

    # Delete subnets
    echo "Deleting subnets..."
    SUBNET_IDS=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[].SubnetId' \
        --output text)
    for subnet in $SUBNET_IDS; do
        aws ec2 delete-subnet --subnet-id $subnet
    done

    # Delete NAT Gateways if any
    echo "Deleting NAT Gateways..."
    NAT_IDS=$(aws ec2 describe-nat-gateways \
        --filter "Name=vpc-id,Values=$VPC_ID" \
        --query 'NatGateways[].NatGatewayId' \
        --output text)
    for nat in $NAT_IDS; do
        aws ec2 delete-nat-gateway --nat-gateway-id $nat
        # Wait for NAT Gateway to be deleted as it takes some time
        aws ec2 wait nat-gateway-deleted --nat-gateway-ids $nat
    done

    # Final attempt to delete VPC
    echo "Deleting VPC..."
    aws ec2 delete-vpc --vpc-id $VPC_ID
fi

echo "Cleanup completed!"
