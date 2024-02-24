#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

bucket_name="bucket_name"
prefix=""

function help_doc {
  echo "Usage: $0 [-h|--help] [bucket_name] [prefix]"
  echo ""
  echo "List files containing 'processed/files' within a specified S3 bucket and its subdirectories."
  echo ""
  echo "Optional arguments:"
  echo "-h, --help    Show this help documentation and exit."
  echo "bucket_name     (optional) Name of the S3 bucket. Defaults to '$bucket_name'."
  echo "prefix         (optional) Prefix to start searching from. Defaults to empty string."
  echo ""
  echo "Example: bash $0 mybucket myprefix"
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  help_doc
  exit 0
fi

# Ensure AWS CLI is installed and configured
if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed or not in PATH."
  exit 1
fi

# Check for AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "Error: AWS credentials not configured."
  exit 1
fi

while true; do
  result=$(aws s3api list-objects --bucket "$bucket_name" --delimiter "/" --prefix "$prefix")
  prefixes=$(jq -r '.CommonPrefixes[].Prefix' <<< "$result")

  if [[ -z "$prefixes" ]]; then
    break
  fi

  for prefix in $prefixes; do
    files=$(aws s3api list-objects --bucket "$bucket_name" --prefix "$prefix")
    file_list=$(jq -r '.Contents[].Key' <<< "$files")

    for file in $file_list; do
      if [[ "$file" == *"processed/files"* ]]; then
        echo "Found $file"
      fi
    done
  done

  prefix="${prefix%/}/$"  # Ensure a trailing slash for subsequent calls
done
