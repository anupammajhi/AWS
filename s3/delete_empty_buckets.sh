#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0"
    echo "This script searches for empty S3 buckets without versioning enabled and deletes them."
    exit 0
fi

s3_client=$(aws s3api)
s3=$(aws s3)

response=$(s3_client list-buckets)
buckets=$(echo $response | jq '.Buckets')

empty_buckets=()
for bucket in $buckets; do
    bucket_name=$(echo $bucket | jq -r '.Name')
    result=$(s3_client list-objects-v2 --bucket $bucket_name)
    if [ "$(echo $result | jq '.Contents')" == "[]" ]; then
        versioning=$(s3_client get-bucket-versioning --bucket $bucket_name)
        if [ "$(echo $versioning | jq -r '.Status')" != "Enabled" ]; then
            empty_buckets+=($bucket_name)
        fi
    fi
done

