#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    echo "This script assigns AWS Single Sign-On (SSO) access to a specified principal (user or group) for multiple AWS accounts within a specified Organizational Unit (OU)."
    echo "Usage: ./script.sh"
    exit
fi

# Replace these variables with your values
PRINCIPAL_NAME="Administrators"  # e.g., 'user_name' or 'group_name'
PRINCIPAL_TYPE="GROUP"  # e.g., 'USER' or 'GROUP'
PERMISSION_SET_NAME="AdministratorAccess"
OU_NAME="Sandbox"  # Replace with the OU name you want to fetch accounts from

# Function to get instance information from AWS SSO
get_instance_information() {
    response=$(aws sso-admin list-instances)
    if [[ -z $response ]]; then
        echo "No SSO instances found"
        exit 1
    fi
    instance_info=$(echo $response | jq -r '.Instances[0]')
    echo $instance_info | jq -r '.InstanceArn, .IdentityStoreId'
}

# Function to get account IDs in an Organizational Unit (OU) given its name
get_accounts_in_ou() {
    root_id=$(aws organizations list-roots | jq -r '.Roots[0].Id')
    ou_id=$(aws organizations list-organizational-units-for-parent --parent-id $root_id | jq -r --arg ou "$OU_NAME" '.OrganizationalUnits[] | select(.Name == $ou) | .Id')
    if [[ -z $ou_id ]]; then
        echo "Organizational Unit not found: $OU_NAME"
        exit 1
    fi
    accounts=$(aws organizations list-accounts-for-parent --parent-id $ou_id | jq -r '.Accounts[].Id')
    echo $accounts
}

# Get the principal ID for the specified principal name and type
get_principal_id() {
    identity_store_id=$1
    principal_name=$2
    principal_type=$3
    filter='{"AttributePath": "UserName" if principal_type == "USER" else "DisplayName","AttributeValue": principal_name}'
    response=$(aws identitystore list-users --identity-store-id $identity_store_id --filters $filter)
    if [[ ! $(echo $response | jq -r '.Users') && ! $(echo $response | jq -r '.Groups') ]]; then
        echo "Principal not found: $principal_name"
        exit 1
    fi
    principal_id=$(echo $response | jq -r --arg principal_type "$principal_type" '.[$principal_type + "s"][0]."${principal_type}Id"')
    echo $principal_id
}

# Get the Permission Set ARN for the specified Permission Set name
get_permission_set_arn() {
    instance_arn=$1
    permission_set_name=$2
    response=$(aws sso-admin list-permission-sets --instance-arn $instance_arn)
    for permission_set_arn in $(echo $response | jq -r '.PermissionSets[]'); do
        permission=$(aws sso-admin describe-permission-set --instance-arn $instance_arn --permission-set-arn $permission_set_arn)
        if [[ $(echo $permission | jq -r '.PermissionSet.Name') == $permission_set_name ]]; then
            echo $permission_set_arn
            return
        fi
    done
    echo "Permission set not found: $permission_set_name"
    exit 1
}

# Assign access to the principal for each account in the OU
assign_access_to_principal() {
    instance_arn=$1
    principal_id=$2
    account_id=$3
    permission_set_arn=$4
    aws sso-admin create-account-assignment --instance-arn $instance_arn --target-id $account_id --target-type "AWS_ACCOUNT" --principal-type $PRINCIPAL_TYPE --principal-id $principal_id --permission-set-arn $permission_set_arn
    echo "Assigned $PRINCIPAL_TYPE $PRINCIPAL_NAME with Permission Set $PERMISSION_SET_NAME in AWS Account $account_id"
}

main() {
    read instance_arn identity_store_id < <(get_instance_information)
    principal_id=$(get_principal_id $identity_store_id $PRINCIPAL_NAME $PRINCIPAL_TYPE)
    permission_set_arn=$(get_permission_set_arn $instance_arn $PERMISSION_SET_NAME)
    account_ids=$(get_accounts_in_ou)
    for account_id in $account_ids; do
        assign_access_to_principal $instance_arn $principal_id $account_id $permission_set_arn
    done
}

main


