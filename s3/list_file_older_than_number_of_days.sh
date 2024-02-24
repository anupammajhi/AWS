#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help documentation function
show_help() {
    echo "This script allows you to list all files older than N numbers of days."
    echo "Usage: bash $0 [N]"
    exit 0
}

# Check if the argument is for help
if [ "$1" = "help" ] || [ "$1" = "h" ] || [ "$1" = "--help" ]; then
    show_help
fi

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide the number of days as argument."
    show_help
fi

# Assign the value of N
days_threshold=$1

# Retrieve file list from S3 and process
response=$(aws s3api list-objects --bucket angularbuildbucket --query 'Contents[].{Key: Key, LastModified: LastModified}' --output json)

today_date_time=$(date +%Y-%m-%d)

for row in $(echo "${response}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

    file_name=$(_jq '.Key')
    modified_time=$(_jq '.LastModified')
    difference_days=$(( ( $(date +%s) - $(date -d "$modified_time" +%s) ) / (60*60*24) ))

    if [ $difference_days -gt $days_threshold ]; then
        echo "file more than $days_threshold days older: $file_name"
    fi
done