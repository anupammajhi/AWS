#!/usr/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS
# This script shows Elastic IP addresses which haven't been associated yet.

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  echo "Usage: $0"
  echo "This script shows Elastic IP addresses which haven't been associated yet."
  exit 0
fi

# Get the list of Elastic IP addresses that haven't been associated
not_assigned_ip=$(aws ec2 describe-addresses --query 'Addresses[?AssociationId==`null`].PublicIp' --output text)

# Print the list of not assigned IP addresses
echo "$not_assigned_ip"