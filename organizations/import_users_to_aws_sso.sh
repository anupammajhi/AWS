
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
