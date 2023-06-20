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
    access_key_metadata=$($iam_client iam create-access-key --user-name "$1")
    access_key=$(echo "$access_key_metadata" | jq -r '.AccessKey.AccessKeyId')
    secret_key=$(echo "$access_key_metadata" | jq -r '.AccessKey.SecretAccessKey')
    echo "Your new access key is $access_key and your new secret key is $secret_key"
}

disable_key() {
    read -p "Do you want to disable the access key $1? [y/N] " answer
    if [ "$answer" == "y" ]; then
        $iam_client iam update-access-key --user-name "$username" --access-key-id "$1" --status Inactive
        echo "$1 has been disabled."
