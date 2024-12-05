#!/bin/bash
export AWS_DEFAULT_REGION="us-east-1"
PREFIX="memo-lab12"

echo "=== Starting cleanup process ==="

echo "=== Cleaning up SNS Subscriptions ==="
# List and delete subscriptions containing memo-lab12
for sub in $(aws sns list-subscriptions --query "Subscriptions[?contains(Endpoint, '${PREFIX}') || contains(TopicArn, '${PREFIX}')].SubscriptionArn" --output text); do
    echo "Deleting subscription: $sub"
    aws sns unsubscribe --subscription-arn "$sub" || true
done

echo "=== Cleaning up IAM Users ==="
for username in $(aws iam list-users --query "Users[?starts_with(UserName, '${PREFIX}')].UserName" --output text); do
    echo "Processing user: $username"
    
    echo "- Deleting login profile for $username"
    aws iam delete-login-profile --user-name "$username" 2>/dev/null || true
    
    echo "- Cleaning up MFA devices for $username"
    for mfa in $(aws iam list-virtual-mfa-devices --query "VirtualMFADevices[?contains(SerialNumber, '$username')].SerialNumber" --output text); do
        echo "  Deactivating and deleting MFA device: $mfa"
        aws iam deactivate-mfa-device --user-name "$username" --serial-number "$mfa" 2>/dev/null || true
        aws iam delete-virtual-mfa-device --serial-number "$mfa" || true
    done
    
    echo "- Cleaning up access keys for $username"
    for key in $(aws iam list-access-keys --user-name "$username" --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
        echo "  Deleting access key: $key"
        aws iam delete-access-key --user-name "$username" --access-key-id "$key" || true
    done
    
    echo "- Removing user $username from groups"
    for group in $(aws iam list-groups-for-user --user-name "$username" --query 'Groups[*].GroupName' --output text); do
        echo "  Removing from group: $group"
        aws iam remove-user-from-group --user-name "$username" --group-name "$group" || true
    done
    
    echo "- Deleting user: $username"
    aws iam delete-user --user-name "$username" || true
done

echo "=== Cleaning up IAM Groups ==="
for groupname in $(aws iam list-groups --query "Groups[?starts_with(GroupName, '${PREFIX}')].GroupName" --output text); do
    echo "Processing group: $groupname"
    
    echo "- Removing users from group $groupname"
    for user in $(aws iam get-group --group-name "$groupname" --query 'Users[*].UserName' --output text); do
        echo "  Removing user: $user"
        aws iam remove-user-from-group --user-name "$user" --group-name "$groupname" || true
    done
    
    echo "- Detaching policies from group $groupname"
    for policy in $(aws iam list-attached-group-policies --group-name "$groupname" --query 'AttachedPolicies[*].PolicyArn' --output text); do
        echo "  Detaching policy: $policy"
        aws iam detach-group-policy --group-name "$groupname" --policy-arn "$policy" || true
    done
    
    echo "- Deleting group: $groupname"
    aws iam delete-group --group-name "$groupname" || true
done

echo "=== Verifying Cleanup ==="
echo "Checking for remaining users:"
aws iam list-users --query "Users[?starts_with(UserName, '${PREFIX}')]"

echo "Checking for remaining groups:"
aws iam list-groups --query "Groups[?starts_with(GroupName, '${PREFIX}')]"

echo "Checking for remaining subscriptions:"
aws sns list-subscriptions --query "Subscriptions[?contains(Endpoint, '${PREFIX}') || contains(TopicArn, '${PREFIX}')]"

echo "=== Cleanup process completed ==="
