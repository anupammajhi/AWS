
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 [OU_NAME]"
    exit
fi

PRINCIPAL_NAME="Administrators"
PRINCIPAL_TYPE="GROUP"
PERMISSION_SET_NAME="AWSAdministratorAccess"
OU_NAME="$1"

get_instance_information() {
    response=$(aws sso-admin list-instances)
    instance_arn=$(echo $response | jq -r '.Instances[0].InstanceArn')
    identity_store_id=$(echo $response | jq -r '.Instances[0].IdentityStoreId')
    echo "$instance_arn $identity_store_id"
}

