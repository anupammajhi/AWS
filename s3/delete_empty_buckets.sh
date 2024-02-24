#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0"
    echo "This script searches for empty S3 buckets without versioning enabled and deletes them."
    exit 0
fi

response=$(aws s3api list-buckets)
buckets=$(echo $response | jq '.Buckets')

empty_buckets=()
for bucket in $buckets; do
    bucket_name=$(echo $bucket | jq -r '.Name')
    result=$(aws s3api list-objects-v2 --bucket $bucket_name)
    if [ "$(echo $result | jq '.Contents')" == "[]" ]; then
        versioning=$(aws s3api get-bucket-versioning --bucket $bucket_name)
        if [ "$(echo $versioning | jq -r '.Status')" != "Enabled" ]; then
            empty_buckets+=($bucket_name)
        fi
    fi
done

for bucket_name in "${empty_buckets[@]}"; do
    aws s3 rm s3://$bucket_name --recursive
    echo "Bucket $bucket_name deleted."
done

