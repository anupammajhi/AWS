#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Check if the first argument is 'help'
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  echo "This script deletes all AWS security groups in a specified region that have a specific tag."
  echo "It first fetches the account ID, then finds security groups with the matching tag."
  echo "If no such security groups are found, it exits."
  echo "Otherwise, it iterates over the found security groups, revokes their permissions (if necessary), and deletes them."
  echo "Usage: $0"
  exit 0
fi


# AWS Region
REGION="us-east-2"

# Tag Key and Value
TAG_KEY="ManagedByAmazonSageMakerResource"
TAG_VALUE_CONTAINS="arn:aws:sagemaker:${REGION}:"

# Fetch Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Find security groups with matching tag
FILTER="Filters=[{\"Name\":\"tag:Key\",\"Values\":[\"${TAG_KEY}\"]},{\"Name\":\"tag:Value\",\"Values\":[\"*\"]}]"
SECURITY_GROUPS=$(aws ec2 describe-security-groups --region ${REGION} ${FILTER} --query 'SecurityGroups[*].GroupId' --output text)

# Check for groups found
if [[ -z "${SECURITY_GROUPS}" ]]; then
  echo "No security groups found with tag ${TAG_KEY} containing ${TAG_VALUE_CONTAINS}"
  exit 0
fi

# Iterate and delete groups
for GROUP_ID in ${SECURITY_GROUPS}; do
  echo "Deleting Security Group: ${GROUP_ID}"

  # Revoke permissions (optional, replace with actual command if needed)
  # aws ec2 revoke-security-group-ingress ... (implement revocation logic)
  # aws ec2 revoke-security-group-egress ...

  aws ec2 delete-security-group --region ${REGION} --group-ids ${GROUP_ID} &> /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Error deleting Security Group: ${GROUP_ID}"
  else
    echo "Security Group ${GROUP_ID} deleted successfully."
  fi
done

echo "Cleanup complete!"
