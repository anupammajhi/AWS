#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
help_function() {
    echo "Usage: $0 <bucket-name>"
    exit 0
}

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    help_function
fi

if [ -z "$1" ]; then
    echo "Please provide the target bucket name as a command line argument"
    exit 1
fi

target_bucket_name=$1

s3_bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

for bucket_name in $s3_bucket_list; do
    if [[ $bucket_name == *"$target_bucket_name"* ]]; then
        echo "Found bucket: $bucket_name"

        versioning_status=$(aws s3api get-bucket-versioning --bucket $bucket_name --query "Status" --output text)

        if [ "$versioning_status" == "Enabled" ]; then
            aws s3 rm s3://$bucket_name --recursive --version-id-marker null
        else
            aws s3 rm s3://$bucket_name --recursive
        fi

        aws s3api delete-bucket --bucket $bucket_name
        echo "Deleted bucket: $bucket_name"
    fi
done

