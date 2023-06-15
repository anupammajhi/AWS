
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 [username]"
    exit 1
fi

username=$1

delete_access_keys() {
    response=$(aws iam list-access-keys --user-name $username)
    for access_key in $(echo $response | jq -r ".AccessKeyMetadata[] | .AccessKeyId"); do
        aws iam delete-access-key --user-name $username --access-key-id $access_key
