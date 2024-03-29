﻿
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

remove_access_from_principal() {
    aws sso-admin delete-account-assignment --instance-arn $1 --target-id $3 --target-type AWS_ACCOUNT --principal-type $2 --principal-id $4 --permission-set-arn $5
    echo "Removed $2 $PRINCIPAL_NAME's Permission Set $PERMISSION_SET_NAME from AWS Account $3"
}

main() {
    IFS=' ' read -r instance_arn identity_store_id <<< $(get_instance_information)
    principal_id=$(get_principal_id $identity_store_id $PRINCIPAL_TYPE $PRINCIPAL_NAME)
    permission_set_arn=$(get_permission_set_arn $instance_arn $PERMISSION_SET_NAME)
    account_ids=($(get_accounts_in_ou $OU_NAME))

    for account_id in "${account_ids[@]}"; do
        remove_access_from_principal $instance_arn $PRINCIPAL_TYPE $account_id $principal_id $permission_set_arn
    done
}

main


