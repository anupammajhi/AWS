#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "This script rotates IAM user keys."
    exit 0
fi

iam_client=$(which aws)

if [ -z "$iam_client" ]; then
    echo "AWS CLI is required for this script to run."
    exit 1
fi

while getopts ":u:k:-:" opt; do
    case $opt in
        u | username)
            username=$OPTARG
            ;;
        k | key)
            aws_access_key=$OPTARG
            ;;
        disable)
            disable_key=true
            ;;
        delete)
            delete_key=true
            ;;
        -)
            case "${OPTARG}" in
