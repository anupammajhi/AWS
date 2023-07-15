
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

get_accounts_in_ou() {
    root_id=$(aws organizations list-roots | jq -r '.Roots[0].Id')
    ou_id=$(aws organizations list-organizational-units-for-parent --parent-id $root_id | jq -r --arg ouName "$1" '.OrganizationalUnits[] | select(.Name == $ouName) | .Id')
    accounts=($(aws organizations list-accounts-for-parent --parent-id $ou_id | jq -r '.Accounts[].Id'))
    echo "${accounts[@]}"
}

get_principal_id() {
    response=$(aws identitystore list-$(echo $2 | tr '[:upper:]' '[:lower:]')s --identity-store-id $1 --filters "UserName=$3" | jq -r '.Users[0].UserId // .Groups[0].GroupId')
    echo "$response"
}

get_permission_set_arn() {
    permission_set_arn=$(aws sso-admin list-permission-sets --instance-arn $1 | jq -r '.PermissionSets[]' | while read arn; do
        name=$(aws sso-admin describe-permission-set --instance-arn $1 --permission-set-arn $arn | jq -r '.PermissionSet.Name')
        [ "$name" == "$2" ] && echo "$arn" && break
    done)
    echo "$permission_set_arn"
}

