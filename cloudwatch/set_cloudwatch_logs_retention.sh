#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ -z $1 ]]; then
    echo "Error: No argument provided. Usage: ./script.sh <retention>"
    exit 1
fi

allowed_values=(1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653)
if [[ ! "${allowed_values[@]}" =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    echo "Invalid retention value. Please choose one of the allowed values: ${allowed_values[@]}"
    exit 1
fi

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    echo "Usage: ./script.sh <retention>"
    echo "Set a retention in days for all your CloudWatch Logs in a single region."
    echo "Possible retention values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
    exit 0
fi

retention=$1
echo "Setting CloudWatch Logs Retention Policy to $retention days for all log groups in the region."

# Check if the log group exists before setting the retention policy
if aws logs describe-log-groups --log-group-name /aws/lambda/* --query 'logGroups[].logGroupName' --output text | grep -q '/aws/lambda/'; then
    aws logs put-retention-policy --log-group-name /aws/lambda/* --retention-in-days $retention
else
    echo "Log group does not exist"
fi

exit 0