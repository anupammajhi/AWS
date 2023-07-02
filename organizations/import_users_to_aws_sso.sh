﻿
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    echo "Usage: ./script.sh <csv_file>"
    echo "Import users from a CSV file to AWS SSO"
    exit
fi

# Add your AWS credentials here if needed
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="your_aws_region"

# Create boto3 clients
sso_admin_client="boto3.client('sso-admin')"
identitystore_client="boto3.client('identitystore')"

# Function to get Identity Store information
get_instance_information() {
    response=$($sso_admin_client list_instances)
    if [[ -z $(echo $response | jq -r '.Instances') ]]; then
        echo "No SSO instances found"
        exit 1
    fi
    instance_info=$(echo $response | jq -r '.Instances[0].IdentityStoreId')
    echo $instance_info
}

# Function to find a group based on group name
find_group() {
    identity_store_id=$1
    group_name=$2
    next_token=""
    while true; do
        response=$(identitystore_client list_groups --IdentityStoreId $identity_store_id --NextToken $next_token)
        for group in $(echo $response | jq -c '.Groups[]'); do
            if [[ $(echo $group | jq -r '.DisplayName') == "$group_name" ]]; then
                group_id=$(echo $group | jq -r '.GroupId')
                echo $group_id
                return
            fi
        done
        next_token=$(echo $response | jq -r '.NextToken')
        if [[ -z $next_token ]]; then
            break
        fi
    done
    echo ""
}

# Function to create a group based on group name
create_group() {
    identity_store_id=$1
    group_name=$2
    group=$(identitystore_client create_group --IdentityStoreId $identity_store_id --DisplayName $group_name)
    echo "Group $group_name created"
    echo $(echo $group | jq -r '.GroupId')
}

# Function to create a group if it doesn't exist
create_group_if_not_exists() {
    group_id=$(find_group $1 $2)
    if [[ -z $group_id ]]; then
        group_id=$(create_group $1 $2)
    fi
    echo $group_id
}

# Function to create a user based on first name, last name, and email
create_user() {
    identity_store_id=$1
    first_name=$2
    last_name=$3
    email=$4
    user_id=$(find_user_by_email $identity_store_id $email)

    if [[ -n $user_id ]]; then
        echo "User $email already exists."
        echo $user_id
        return
    fi

    response=$(identitystore_client create_user --IdentityStoreId $identity_store_id --UserName $email --Name "{\"Formatted\": \"$first_name $last_name\", \"FamilyName\": \"$last_name\", \"GivenName\": \"$first_name\"}" --DisplayName "$first_name $last_name" --Emails "[{\"Value\": \"$email\", \"Type\": \"Work\", \"Primary\": true}]")
    user_id=$(echo $response | jq -r '.UserId')
    echo "Created user $email"
    echo $user_id
