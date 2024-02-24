#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "This script finds and deletes all tagged elastic file systems including mount targets"
    exit 0
fi

# Fetch AWS account ID from boto3 session
account_id=$(aws sts get-caller-identity --query Account --output text)
aws_region="eu-central-1"

# Modify the tag key and value to your own liking
tag_key="ManagedByAmazonSageMakerResource"
tag_value_contains="arn:aws:sagemaker:${aws_region}:${account_id}:domain"

function find_efs_filesystems {
    response=$(aws efs describe-file-systems)

    filtered_filesystems=$(echo "$response" | jq -r --arg tag_key "$tag_key" --arg tag_value_contains "$tag_value_contains" '.FileSystems[] | select(.Tags[]? | .Key == $tag_key and .Value | contains($tag_value_contains))')

    echo "$filtered_filesystems"
}

function delete_mount_targets {
    filesystem_id=$1
    response=$(aws efs describe-mount-targets --file-system-id $filesystem_id)

    for mt in $(echo "$response" | jq -r '.MountTargets[]'); do
        mount_target_id=$(echo "$mt" | jq -r '.MountTargetId')
        aws efs delete-mount-target --mount-target-id $mount_target_id
        echo "Deleted Mount Target: $mount_target_id"
    done
}

function delete_efs_filesystem {
    filesystem_id=$1
    max_retries=5
    current_retry=0

    while [ "$current_retry" -lt "$max_retries" ]; do
        delete_mount_targets "$filesystem_id"

        delay=$((2**current_retry + RANDOM))
        echo "Waiting for $delay seconds before attempting to delete the EFS filesystem."
        sleep $delay

        aws efs delete-file-system --file-system-id $filesystem_id
        echo "Deleted EFS Filesystem: $filesystem_id"
        break
    done
}

efs_filesystems=$(find_efs_filesystems)

for fs in $efs_filesystems; do
    filesystem_id=$(echo "$fs" | jq -r '.FileSystemId')
    delete_efs_filesystem "$filesystem_id"
done