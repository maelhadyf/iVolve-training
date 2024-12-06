#!/bin/bash

# Exit on any error
set -e

# Enable debug mode (uncomment to see detailed execution)
# set -x

# Configuration variables
BUCKET_NAME="memo-lab15-bucket-$(date +%s)"
LOG_BUCKET="memo-lab15-logs-${BUCKET_NAME}"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Function to create and configure logging bucket
create_log_bucket() {
    print_status "Creating logging bucket: $LOG_BUCKET"
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$LOG_BUCKET" \
            --region "$REGION" \
            --object-ownership ObjectWriter
    else
        aws s3api create-bucket \
            --bucket "$LOG_BUCKET" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION" \
            --object-ownership ObjectWriter
    fi

    # Add tags to logging bucket
    aws s3api put-bucket-tagging \
        --bucket "$LOG_BUCKET" \
        --tagging "TagSet=[{Key=Project,Value=memo-lab15},{Key=Environment,Value=Logging}]"

    # Configure bucket ownership controls
    aws s3api put-bucket-ownership-controls \
        --bucket "$LOG_BUCKET" \
        --ownership-controls Rules=[{ObjectOwnership=ObjectWriter}]

    # Set bucket policy for log delivery
    aws s3api put-bucket-policy \
        --bucket "$LOG_BUCKET" \
        --policy "{
            \"Version\": \"2012-10-17\",
            \"Statement\": [
                {
                    \"Sid\": \"S3ServerAccessLogsPolicy\",
                    \"Effect\": \"Allow\",
                    \"Principal\": {
                        \"Service\": \"logging.s3.amazonaws.com\"
                    },
                    \"Action\": [
                        \"s3:PutObject\"
                    ],
                    \"Resource\": \"arn:aws:s3:::${LOG_BUCKET}/*\",
                    \"Condition\": {
                        \"StringEquals\": {
                            \"aws:SourceAccount\": \"${ACCOUNT_ID}\"
                        }
                    }
                }
            ]
        }"
}

# Function to create and configure main bucket
create_bucket() {
    print_status "Creating bucket: $BUCKET_NAME"
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$REGION"
    else
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"
    fi

    # Add tags to bucket
    aws s3api put-bucket-tagging \
        --bucket "$BUCKET_NAME" \
        --tagging "TagSet=[{Key=Project,Value=memo-lab15},{Key=Environment,Value=Development}]"

    print_status "Enabling versioning"
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled

    print_status "Enabling logging"
    aws s3api put-bucket-logging \
        --bucket "$BUCKET_NAME" \
        --bucket-logging-status "{
            \"LoggingEnabled\": {
                \"TargetBucket\": \"$LOG_BUCKET\",
                \"TargetPrefix\": \"memo-lab15-logs/\"
            }
        }"

    print_status "Setting bucket policy"
    aws s3api put-bucket-policy \
        --bucket "$BUCKET_NAME" \
        --policy "{
            \"Version\": \"2012-10-17\",
            \"Statement\": [
                {
                    \"Sid\": \"memo-lab15-access\",
                    \"Effect\": \"Allow\",
                    \"Principal\": {
                        \"AWS\": \"arn:aws:iam::$ACCOUNT_ID:root\"
                    },
                    \"Action\": [
                        \"s3:GetObject\",
                        \"s3:PutObject\"
                    ],
                    \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\"
                }
            ]
        }"
}

# Function to upload test file
upload_test_file() {
    print_status "Creating and uploading test file"
    echo "This is a memo-lab15 test file" > memo-lab15-test.txt
    
    # Upload file with tags
    aws s3api put-object \
        --bucket "$BUCKET_NAME" \
        --key "memo-lab15-test.txt" \
        --body memo-lab15-test.txt \
        --tagging "Project=memo-lab15&Environment=Testing"
    
    rm memo-lab15-test.txt
}

# Function to list bucket details
list_bucket_details() {
    print_status "Listing bucket details"
    
    echo -e "\nMain Bucket Tags:"
    aws s3api get-bucket-tagging --bucket "$BUCKET_NAME"
    
    echo -e "\nLogging Bucket Tags:"
    aws s3api get-bucket-tagging --bucket "$LOG_BUCKET"
    
    echo -e "\nLogging Configuration:"
    aws s3api get-bucket-logging --bucket "$BUCKET_NAME"
    
    echo -e "\nMain Bucket Contents:"
    aws s3 ls "s3://$BUCKET_NAME"
}

# Main execution
main() {
    # Check AWS CLI configuration
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${RED}Error: AWS CLI is not configured. Please run 'aws configure' first.${NC}"
        exit 1
    fi

    print_status "Starting memo-lab15 S3 bucket creation and configuration"
    
    # Create logging bucket first
    create_log_bucket
    
    # Create and configure main bucket
    create_bucket
    
    # Upload test file
    upload_test_file
    
    # List bucket details
    list_bucket_details
    
    print_status "memo-lab15 configuration complete!"
    echo -e "${GREEN}Main bucket:${NC} $BUCKET_NAME"
    echo -e "${GREEN}Logging bucket:${NC} $LOG_BUCKET"
}

# Run the script
main
