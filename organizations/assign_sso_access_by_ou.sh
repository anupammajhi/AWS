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
