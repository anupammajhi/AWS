#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

bucket_name="bucket_name"
prefix=""

function show_help() {
  echo "Usage: $0 [-h] [-b bucket_name] [-p prefix]"
  echo "-h, --help     Show this help message and exit."
  echo "-b, --bucket     Specify the S3 bucket name (default: $bucket_name)."
  echo "-p, --prefix     Specify a prefix to filter files (default: $prefix)."
  echo ""
  echo "This script lists files in an S3 bucket, optionally within a specific prefix."
  echo "If no arguments are provided, it uses the default bucket name and prefix."
  exit 0
}


if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  show_help
  exit 0
fi

# Check if required options are provided
if [[ -z $bucket_name ]]; then
    echo "Error: Bucket name is required"
    display_help
    exit 1
fi

# List objects in the bucket with specified prefix
objects=$(aws s3 ls s3://$bucket_name/$prefix --recursive)

# Loop through the objects and print those with 'processed/files' in the key
while read -r line; do
    key=$(echo "$line" | awk '{print $4}')
    if [[ $key == *"processed/files"* ]]; then
        echo "Found $key"
    fi
done <<< "$objects"