#!/bin/bash

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Set region
REGION="us-east-1"  # Change to your region if different

echo "Starting cleanup of resources with prefix 'memo-lab16'..."

# Delete API Gateway
echo "Deleting API Gateway..."
API_ID=$(aws apigatewayv2 get-apis --query "Items[?contains(Name, 'memo-lab16')].ApiId" --output text)
if [ ! -z "$API_ID" ]; then
    aws apigatewayv2 delete-api --api-id $API_ID
    echo "API Gateway deleted"
fi

# Delete Lambda function
echo "Deleting Lambda function..."
aws lambda delete-function --function-name "memo-lab16-ItemsAPIFunction" 2>/dev/null
echo "Lambda function deleted"

# Delete IAM role policies and role
echo "Deleting IAM role and policies..."
ROLE_NAME="memo-lab16-ItemsAPILambdaRole"

# Detach managed policies
aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null

# Delete inline policies
aws iam delete-role-policy --role-name $ROLE_NAME --policy-name memo-lab16-DynamoDBAccess 2>/dev/null

# Delete the role
aws iam delete-role --role-name $ROLE_NAME 2>/dev/null
echo "IAM role and policies deleted"

# Delete DynamoDB table
echo "Deleting DynamoDB table..."
aws dynamodb delete-table --table-name "memo-lab16-Items" 2>/dev/null
echo "DynamoDB table deletion initiated"

echo "Cleanup completed!"
