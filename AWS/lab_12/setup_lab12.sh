#!/bin/bash

# Set your AWS region
export AWS_DEFAULT_REGION="us-east-1"

echo "Starting AWS Setup Script..."

# Create Groups
echo "Creating IAM Groups..."
aws iam create-group --group-name memo-lab12-admin-developer
aws iam create-group --group-name memo-lab12-developer

# Attach policies to groups
echo "Attaching policies to groups..."
aws iam attach-group-policy --group-name memo-lab12-admin-developer --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam attach-group-policy --group-name memo-lab12-developer --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

# Create Users
echo "Creating Users..."

# Create admin-1 (Console Access)
aws iam create-user --user-name memo-lab12-admin-1
aws iam create-login-profile --user-name memo-lab12-admin-1 --password "Admin1Pass123!" --password-reset-required
aws iam add-user-to-group --user-name memo-lab12-admin-1 --group-name memo-lab12-admin-developer

# Setup Virtual MFA for admin-1
echo "Setting up MFA for memo-lab12-admin-1..."

# Create a specific directory for MFA setup
MFA_DIR=~/aws-mfa-setup
mkdir -p "$MFA_DIR"
QR_CODE_PATH="$MFA_DIR/memo-lab12-admin-1-qr.png"

# Check and remove existing unassigned MFA device if it exists
echo "Checking for existing MFA devices..."
EXISTING_MFA=$(aws iam list-virtual-mfa-devices --assignment-status Unassigned \
    --query "VirtualMFADevices[?SerialNumber.contains(@,'memo-lab12-admin-1-mfa')].SerialNumber" \
    --output text)

if [ ! -z "$EXISTING_MFA" ]; then
    echo "Found existing unassigned MFA device. Removing it..."
    aws iam delete-virtual-mfa-device --serial-number "$EXISTING_MFA"
    echo "Existing MFA device removed."
    # Wait a moment for AWS to process the deletion
    sleep 5
fi

# Create virtual MFA device with error checking
if aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name memo-lab12-admin-1-mfa \
    --outfile "$QR_CODE_PATH" \
    --bootstrap-method QRCodePNG; then
    
    # Get MFA ARN
    MFA_ARN=$(aws iam list-virtual-mfa-devices \
        --assignment-status Unassigned \
        --query "VirtualMFADevices[?SerialNumber.contains(@,'memo-lab12-admin-1-mfa')].SerialNumber" \
        --output text)

    # Verify file exists
    if [ -f "$QR_CODE_PATH" ]; then
        echo "QR code has been generated at: $QR_CODE_PATH"
        echo "Please scan this QR code with your MFA app (like Google Authenticator)"
        echo "MFA Device ARN: $MFA_ARN"

        # Display file information
        ls -l "$QR_CODE_PATH"

        # Wait for user to scan QR code and get MFA codes
        echo "After scanning the QR code, please wait for two consecutive MFA codes"
        read -p "Enter the first MFA code: " CODE1
        read -p "Enter the second MFA code: " CODE2

        # Enable MFA device
        aws iam enable-mfa-device \
            --user-name memo-lab12-admin-1 \
            --serial-number "$MFA_ARN" \
            --authentication-code1 "$CODE1" \
            --authentication-code2 "$CODE2"

        echo "MFA enabled for memo-lab12-admin-1"

        # Cleanup temporary MFA files
        rm -f "$QR_CODE_PATH"
        rmdir "$MFA_DIR"
    else
        echo "Error: QR code file was not created at $QR_CODE_PATH"
        exit 1
    fi
else
    echo "Error: Failed to create virtual MFA device"
    exit 1
fi

# Create admin-2-prog (CLI Access)
aws iam create-user --user-name memo-lab12-admin-2-prog
ADMIN_2_KEYS=$(aws iam create-access-key --user-name memo-lab12-admin-2-prog)
aws iam add-user-to-group --user-name memo-lab12-admin-2-prog --group-name memo-lab12-admin-developer

# Create dev-user (Both Console and CLI Access)
aws iam create-user --user-name memo-lab12-dev-user
aws iam create-login-profile --user-name memo-lab12-dev-user --password "DevPass123!" --password-reset-required
DEV_KEYS=$(aws iam create-access-key --user-name memo-lab12-dev-user)
aws iam add-user-to-group --user-name memo-lab12-dev-user --group-name memo-lab12-developer

# Create Billing Alarm
echo "Creating Billing Alarm..."
SNS_TOPIC_ARN=$(aws sns create-topic --name memo-lab12-billing-alarm --output text)

# Create SNS subscription
echo "Setting up email subscription for billing alerts..."
read -p "Enter your email address for billing alerts: " EMAIL_ADDRESS

# Subscribe email to SNS topic
aws sns subscribe \
    --topic-arn "$SNS_TOPIC_ARN" \
    --protocol email \
    --notification-endpoint "$EMAIL_ADDRESS"

echo "Please check your email and confirm the subscription"

aws cloudwatch put-metric-alarm \
    --alarm-name "memo-lab12-BillingAlarm" \
    --alarm-description "Billing amount exceeded threshold" \
    --metric-name "EstimatedCharges" \
    --namespace "AWS/Billing" \
    --statistic Maximum \
    --period 21600 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 1 \
    --alarm-actions "$SNS_TOPIC_ARN" \
    --dimensions Name=Currency,Value=USD

# List all users and groups
echo -e "\nListing all IAM Users:"
aws iam list-users --output table

echo -e "\nListing all IAM Groups:"
aws iam list-groups --output table

# List group memberships
echo -e "\nListing memo-lab12-admin-developer group members:"
aws iam get-group --group-name memo-lab12-admin-developer --output table

echo -e "\nListing memo-lab12-developer group members:"
aws iam get-group --group-name memo-lab12-developer --output table

echo -e "\nSetup Complete!"
echo "Important: Please save the following credentials securely"
echo "Admin-2 Programmatic Access Keys:"
echo "$ADMIN_2_KEYS"
echo -e "\nDev-User Access Keys:"
echo "$DEV_KEYS"
echo -e "\nRemember to:"
echo "1. MFA has been enabled for memo-lab12-admin-1 user"
echo "2. Change temporary passwords at first login"
echo "3. Store access keys securely"
echo "4. The subscription must be confirmed via email"
