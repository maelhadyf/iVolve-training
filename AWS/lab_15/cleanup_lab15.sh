#!/bin/bash

# List all buckets and store them in an array
BUCKETS=($(aws s3api list-buckets --query 'Buckets[].Name' --output text))

# Function to empty a bucket including all versions
empty_bucket() {
    local bucket=$1
    echo "Emptying bucket: $bucket"
    
    # First, remove all versions
    echo "Removing all object versions..."
    aws s3api list-object-versions --bucket "$bucket" --output text --query 'Versions[*].[Key,VersionId]' | \
    while read -r key version; do
        if [ ! -z "$key" ] && [ ! -z "$version" ]; then
            echo "Deleting object: $key (version $version)"
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version"
        fi
    done

    # Then, remove all delete markers
    echo "Removing all delete markers..."
    aws s3api list-object-versions --bucket "$bucket" --output text --query 'DeleteMarkers[*].[Key,VersionId]' | \
    while read -r key version; do
        if [ ! -z "$key" ] && [ ! -z "$version" ]; then
            echo "Deleting delete marker: $key (version $version)"
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version"
        fi
    done

    # Finally, remove any remaining non-versioned objects
    echo "Removing any remaining objects..."
    aws s3 rm "s3://$bucket" --recursive
}

# Filter buckets that start with memo-lab15
FILTERED_BUCKETS=()
for bucket in "${BUCKETS[@]}"; do
    if [[ $bucket == memo-lab15* ]]; then
        FILTERED_BUCKETS+=("$bucket")
    fi
done

# Ask for confirmation
echo "This will delete all S3 buckets that start with 'memo-lab15' in your account."
echo "Found ${#FILTERED_BUCKETS[@]} matching buckets:"
for bucket in "${FILTERED_BUCKETS[@]}"; do
    echo "  - $bucket"
done

read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Process each filtered bucket
for bucket in "${FILTERED_BUCKETS[@]}"; do
    echo "Processing bucket: $bucket"
    
    # Empty the bucket first (including all versions)
    empty_bucket "$bucket"
    
    # Delete the bucket
    echo "Deleting bucket: $bucket"
    aws s3api delete-bucket --bucket "$bucket"
    
    if [ $? -eq 0 ]; then
        echo "Successfully deleted bucket: $bucket"
    else
        echo "Failed to delete bucket: $bucket"
    fi
done

echo "Operation completed."
