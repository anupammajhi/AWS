﻿#!/bin/bash
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
                disable)
                    disable_key=true
                    ;;
                delete)
                    delete_key=true
                    ;;
            esac
            ;;
    esac
done

create_key() {
    keys=$($iam_client iam list-access-keys --user-name "$1" | jq -r '.AccessKeyMetadata')
    key_count=$(echo "$keys" | jq length)
    if [ "$key_count" -ge 2 ]; then
        echo "$1 already has 2 keys. You must delete a key before you can create another key."
        return
    fi
