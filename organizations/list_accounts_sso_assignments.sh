#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help documentation function
show_help() {
    cat << EOF
Usage: $0 [options]

This script retrieves AWS SSO account assignments and outputs them in JSON format.

Options:
  -h, --help    Display this help and exit
EOF
}

# Function to get all AWS accounts
get_all_accounts() {
    aws organizations list-accounts --output json | jq -r '.Accounts[]'
}

# Function to get all permission sets
get_all_permission_sets() {
    local instance_arn="$1"
    aws sso-admin list-permission-sets --instance-arn "$instance_arn" --output json | jq -r '.PermissionSets[].PermissionSetArn'
}

# Function to get account assignments
get_account_assignments() {
    local account_id="$1"
    local instance_arn="$2"
    local permission_set_arn="$3"
    aws sso-admin list-account-assignments --account-id "$account_id" --instance-arn "$instance_arn" --permission-set-arn "$permission_set_arn" --output json | jq -r '.AccountAssignments[]'
}

# Function to get instance information from AWS SSO
get_instance_information() {
    aws sso-admin list-instances --output json | jq -r '.Instances[0] | .InstanceArn, .IdentityStoreId'
}

# Main function
main() {
    local instance_arn identity_store_id
    read -r instance_arn identity_store_id < <(get_instance_information)
    local aws_accounts="$(get_all_accounts)"
    local permission_sets="$(get_all_permission_sets "$instance_arn")"
    local all_account_results="[]"

    while IFS= read -r account; do
        local account_id="$(jq -r '.Id' <<< "$account")"
        local account_name="$(jq -r '.Name' <<< "$account")"
        local account_email="$(jq -r '.Email' <<< "$account")"
        local account_result='{"Name":"'"$account_name"'","Id":"'"$account_id"'","Email":"'"$account_email"'","Assignments":[]}'

        while IFS= read -r permission_set_arn; do
            local account_assignments="$(get_account_assignments "$account_id" "$instance_arn" "$permission_set_arn")"
            while IFS= read -r assignment; do
                # Handle assignment here
                principal_type="$(jq -r '.PrincipalType' <<< "$assignment")"
                principal_id="$(jq -r '.PrincipalId' <<< "$assignment")"
                # More processing...
            done <<< "$account_assignments"
        done <<< "$permission_sets"

        all_account_results+=",$account_result"
    done <<< "$aws_accounts"

    # Output the JSON
    printf '{"Accounts":[%s]}\n' "${all_account_results#,}"
}

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  show_help
  exit 0
fi

# Run main function if no options provided
main "$@"
