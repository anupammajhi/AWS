﻿
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
if [[ $1 == "help" ]] || [[ $1 == "h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: ./script.sh [list of OU names]"
    echo "This script returns a list of accounts that are part of an Organizational Unit (OU)"
    exit
fi

ou_names=("$@")  # Get the list of organizational unit names from command-line arguments

# Create an AWS Organizations client
organizations=$(aws organizations)

# Call the list_roots method to get a list of roots in the organization
root_id=$(aws organizations list_roots --output text --query 'Roots[0].Id')

if [[ -z $ou_names ]]; then
    # If no OU names are provided, list all accounts in the organization
    accounts=$(aws organizations list_accounts --output json --query 'Accounts')

    echo "Found the following accounts for the organization:"
    echo

    for account in $(echo $accounts | jq -c '.[]'); do
        account_id=$(echo $account | jq -r '.Id')
        account_alias=$(echo $account | jq -r '.Alias // .Name')
        ou_name=$(get_ou_for_account $account_id $root_id)
        echo "Account ID: $account_id, Account Alias/Name: $account_alias, Organizational Unit: $ou_name"
    done
else
    # Iterate through the list of OU names and get the ID of each OU
    ou_ids=()

    for ou_name in "${ou_names[@]}"; do
        ou_id=$(aws organizations list_organizational_units_for_parent --parent-id $root_id --output text --query "OrganizationalUnits[?Name=='$ou_name'].Id" | head -n 1)
        ou_ids+=($ou_id)
    done

    accounts=()

    for parent_id in "${ou_ids[@]}"; do
        response=$(aws organizations list_accounts_for_parent --parent-id $parent_id --output json --query 'Accounts')
        accounts+=($(echo $response | jq -c '.[]'))
    done

    echo "Found the following accounts for organizational units: ${ou_names[@]}"
    echo

    for account in "${accounts[@]}"; do
        account_id=$(echo $account | jq -r '.Id')
        account_alias=$(echo $account | jq -r '.Alias // .Name')
        echo "Account ID: $account_id, Account Alias/Name: $account_alias"
    done
fi


