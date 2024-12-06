#!/bin/bash

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Configuration
TABLE_NAME="memo-lab16-Items"
API_NAME="memo-lab16-ItemsAPI"
REGION="us-east-1"  # Change to your region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create DynamoDB table
create_table() {
    echo "Creating DynamoDB table..."
    aws dynamodb create-table \
        --table-name $TABLE_NAME \
        --attribute-definitions AttributeName=id,AttributeType=S \
        --key-schema AttributeName=id,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region $REGION || error_exit "Failed to create table"
    
    # Wait for table to be active
    aws dynamodb wait table-exists --table-name $TABLE_NAME
    echo "Table created successfully"
}

# Create Lambda execution role
create_lambda_role() {
    echo "Creating Lambda execution role..."
    
    # Create role
    ROLE_NAME="memo-lab16-ItemsAPILambdaRole"
    TRUST_POLICY='{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }]
    }'
    
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document "$TRUST_POLICY" || error_exit "Failed to create role"
    
    # Attach policies
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    
    # Create DynamoDB policy
    DYNAMO_POLICY='{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:'$REGION':'$ACCOUNT_ID':table/'$TABLE_NAME'"
        }]
    }'
    
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name memo-lab16-DynamoDBAccess \
        --policy-document "$DYNAMO_POLICY"
    
    # Wait for role to be available
    sleep 10
    
    ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query Role.Arn --output text)
    echo "Role created successfully"
}

# Create Lambda function
create_lambda_function() {
    echo "Creating Lambda function..."
    
    # Create Python file with Lambda code
    cat > lambda_function.py << 'EOL'
import json
import boto3
import os
from uuid import uuid4
from datetime import datetime
import traceback

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        print(f"Received event: {json.dumps(event)}")  # Debug logging
        
        # HTTP API uses requestContext.http.method instead of httpMethod
        http_method = event['requestContext']['http']['method']
        
        if http_method == 'GET':
            if 'pathParameters' in event and event['pathParameters'] and 'id' in event['pathParameters']:
                response = table.get_item(Key={'id': event['pathParameters']['id']})
                item = response.get('Item', {})
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(item)
                }
            else:
                response = table.scan()
                items = response.get('Items', [])
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(items)
                }
                
        elif http_method == 'POST':
            body = json.loads(event.get('body', '{}'))
            item = {
                'id': str(uuid4()),
                'timestamp': datetime.utcnow().isoformat(),
                **body
            }
            table.put_item(Item=item)
            return {
                'statusCode': 201,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(item)
            }
            
        elif http_method == 'PUT':
            body = json.loads(event.get('body', '{}'))
            item_id = event['pathParameters']['id']
            
            update_expression = 'SET '
            expression_values = {}
            
            for key, value in body.items():
                if key != 'id':
                    update_expression += f'#{key} = :{key}, '
                    expression_values[f':{key}'] = value
            
            update_expression = update_expression.rstrip(', ')
            
            table.update_item(
                Key={'id': item_id},
                UpdateExpression=update_expression,
                ExpressionAttributeValues=expression_values,
                ExpressionAttributeNames={f'#{k}': k for k in body.keys() if k != 'id'}
            )
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'message': 'Item updated successfully'})
            }
            
        elif http_method == 'DELETE':
            item_id = event['pathParameters']['id']
            table.delete_item(Key={'id': item_id})
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'message': 'Item deleted successfully'})
            }
            
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'message': 'Invalid HTTP method'})
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        print(f"Traceback: {traceback.format_exc()}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Internal Server Error',
                'error': str(e)
            })
        }
EOL

    # Function to create ZIP file with error handling
    create_zip() {
        echo "Attempting to create ZIP file..."
        
        # Try PowerShell first
        if powershell Compress-Archive -Path lambda_function.py -DestinationPath lambda_function.zip -Force 2>/dev/null; then
            echo "Successfully created ZIP using PowerShell"
            return 0
        fi
        
        # If PowerShell fails, try zip command
        if command -v zip >/dev/null 2>&1; then
            if zip -r lambda_function.zip lambda_function.py; then
                echo "Successfully created ZIP using zip command"
                return 0
            fi
        fi
        
        # If both methods fail
        error_exit "Failed to create ZIP file. Please install zip utility or ensure PowerShell is available"
    }

    # Create the ZIP file
    create_zip

    # Create Lambda function
    FUNCTION_NAME="memo-lab16-ItemsAPIFunction"
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime python3.9 \
        --handler lambda_function.lambda_handler \
        --role $ROLE_ARN \
        --zip-file fileb://lambda_function.zip \
        --environment Variables={TABLE_NAME=$TABLE_NAME} \
        --timeout 30 || error_exit "Failed to create Lambda function"
        
    LAMBDA_ARN=$(aws lambda get-function --function-name $FUNCTION_NAME --query Configuration.FunctionArn --output text)
    echo "Lambda function created successfully"
}

# Create HTTP API
create_api() {
    echo "Creating HTTP API..."
    
    # Create API
    API_ID=$(aws apigatewayv2 create-api \
        --name $API_NAME \
        --protocol-type HTTP \
        --target $LAMBDA_ARN \
        --query ApiId --output text)
    
    # Create Lambda integration
    INTEGRATION_ID=$(aws apigatewayv2 create-integration \
        --api-id $API_ID \
        --integration-type AWS_PROXY \
        --integration-uri $LAMBDA_ARN \
        --payload-format-version 2.0 \
        --query IntegrationId --output text)
    
    echo "Created integration with ID: $INTEGRATION_ID"
    
    # Add routes with the integration ID
    aws apigatewayv2 create-route \
        --api-id $API_ID \
        --route-key "GET /items" \
        --target "integrations/$INTEGRATION_ID"
        
    aws apigatewayv2 create-route \
        --api-id $API_ID \
        --route-key "GET /items/{id}" \
        --target "integrations/$INTEGRATION_ID"
        
    aws apigatewayv2 create-route \
        --api-id $API_ID \
        --route-key "POST /items" \
        --target "integrations/$INTEGRATION_ID"
        
    aws apigatewayv2 create-route \
        --api-id $API_ID \
        --route-key "PUT /items/{id}" \
        --target "integrations/$INTEGRATION_ID"
        
    aws apigatewayv2 create-route \
        --api-id $API_ID \
        --route-key "DELETE /items/{id}" \
        --target "integrations/$INTEGRATION_ID"
    
    # Add Lambda permission
    aws lambda add-permission \
        --function-name $FUNCTION_NAME \
        --statement-id apigateway \
        --action lambda:InvokeFunction \
        --principal apigateway.amazonaws.com \
        --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*"
    
    API_URL=$(aws apigatewayv2 get-api --api-id $API_ID --query ApiEndpoint --output text)
    echo "API created successfully"
    echo "API URL: $API_URL"
}

# Test functions
test_api() {
    echo "Testing API endpoints..."
    
    # Create item
    echo "Creating item..."
    echo "POST URL: $API_URL/items"
    RESPONSE=$(curl -s -X POST "$API_URL/items" \
        -H "Content-Type: application/json" \
        -d '{"name": "Test Item", "description": "This is a test item"}')
    echo "Create Response: $RESPONSE"
    
    # Extract ID using sed
    ITEM_ID=$(echo $RESPONSE | sed -n 's/.*"id": "\([^"]*\)".*/\1/p')
    echo "Created item ID: $ITEM_ID"
    
    if [ -z "$ITEM_ID" ]; then
        echo "Failed to extract item ID, aborting tests"
        return 1
    fi
    
    # Add small delay to allow changes to propagate
    sleep 2
    
    # Get all items
    echo "Getting all items..."
    echo "GET ALL URL: $API_URL/items"
    ITEMS_RESPONSE=$(curl -s -H "Content-Type: application/json" "$API_URL/items")
    echo "Get All Response: $ITEMS_RESPONSE"
    
    # Add small delay
    sleep 2
    
    # Get single item
    echo "Getting single item..."
    echo "GET SINGLE URL: $API_URL/items/$ITEM_ID"
    SINGLE_RESPONSE=$(curl -s -H "Content-Type: application/json" "$API_URL/items/$ITEM_ID")
    echo "Get Single Response: $SINGLE_RESPONSE"
    
    # Add small delay
    sleep 2
    
    # Update item
    echo "Updating item..."
    echo "PUT URL: $API_URL/items/$ITEM_ID"
    UPDATE_RESPONSE=$(curl -s -X PUT "$API_URL/items/$ITEM_ID" \
        -H "Content-Type: application/json" \
        -d '{"name": "Updated Item"}')
    echo "Update Response: $UPDATE_RESPONSE"
    
    # Add small delay
    sleep 2
    
    # Delete item
    echo "Deleting item..."
    echo "DELETE URL: $API_URL/items/$ITEM_ID"
    DELETE_RESPONSE=$(curl -s -X DELETE -H "Content-Type: application/json" "$API_URL/items/$ITEM_ID")
    echo "Delete Response: $DELETE_RESPONSE"
}

# Main execution
main() {
    create_table
    create_lambda_role
    create_lambda_function
    create_api
    test_api
}

# Run the script
main
