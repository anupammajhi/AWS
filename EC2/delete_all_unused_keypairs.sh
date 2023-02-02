#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Function to display help message
print_help() {
  cat << EOF
  Usage: $0 [OPTIONS]

  This script identifies and deletes unused EC2 key pairs across all AWS regions.

  Options:
    -h, --help     Display this help message and exit.

  Credentials:
    - This script uses the AWS CLI credentials configured in your environment variables
      or in the specified configuration file.
    - For more details, refer to the AWS CLI documentation: https://docs.aws.amazon.com/cli/latest/userguide/install-configure.html

  Example:
    $0

  Note:
    - This script deletes resources. Use caution and test it in a non-production environment before using it on sensitive data.
EOF
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  print_help
  exit
fi

# Initialize variables
unused_keys=()

# Iterate through all regions
for region in $(aws ec2 describe-regions --output text | cut -f3); do

  # Check permission to access the region
  if ! aws ec2 describe-key-pairs --region $region &> /dev/null; then
    echo "Skipping region $region: Access denied"
    continue
  fi

  # List all key pairs and running instances
  key_pairs=$(aws ec2 describe-key-pairs --region $region | jq -r '.KeyPairs[].KeyName')
  running_instances=$(aws ec2 describe-instances --region $region --filters "Name=instance-state-name,Values=running" | jq -r '.Reservations[].Instances[].KeyName')

  # Identify unused key pairs
  for key_pair in $key_pairs; do
    if [[ ! $running_instances =~ "$key_pair" ]]; then
      unused_keys+=("$key_pair($region)")
      aws ec2 delete-key-pair --region $region --key-name $key_pair &> /dev/null
      echo "Deleted unused key pair $key_pair in region $region"
    fi
  done

done

# Print summary
echo "${#unused_keys[@]} unused key pairs found and deleted:"
for key_pair in "${unused_keys[@]}"; do
  echo "  - $key_pair"
done

