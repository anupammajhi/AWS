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
    efs_client="aws efs"
    response=$(eval "$efs_client describe-file-systems")

    filtered_filesystems=""
    for fs in $(echo "$response" | jq -r '.FileSystems[]'); do
