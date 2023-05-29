
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: bash script.sh"
    exit 0
fi

role_arn_to_session() {
    client=$(aws sts assume-role "$@")
    access_key_id=$(echo "$client" | jq -r '.Credentials.AccessKeyId')
    secret_access_key=$(echo "$client" | jq -r '.Credentials.SecretAccessKey')
    session_token=$(echo "$client" | jq -r '.Credentials.SessionToken')
    aws configure set aws_access_key_id $access_key_id
    aws configure set aws_secret_access_key $secret_access_key
    aws configure set aws_session_token $session_token
}

set_boto3_clients() {
    role_arn_to_session --role-arn "arn:aws:iam::$1:role/your-rolename-to-assume" --role-session-name "your-rolename-to-assume"
}

delete_awsconfig_rule_evaluations() {
    aws configservice delete-evaluation-results --config-rule-name "SHIELD_002"
}

lambda_handler() {
    for account_id in "${aws_account_list[@]}"; do
        set_boto3_clients $account_id
        awsconfig=$(aws configure get role_arn)
