
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: bash script.sh"
    exit 0
fi

role_arn_to_session() {
    client=$(aws sts assume-role "$@")
    access_key_id=$(echo "$client" | jq -r '.Credentials.AccessKeyId')
    secret_access_key=$(echo "$client" | jq -r '.Credentials.SecretAccessKey')
