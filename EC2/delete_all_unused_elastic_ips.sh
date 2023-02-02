#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

function print_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "-h, --help        Show this help message and exit."
  echo ""
  echo "This script finds and releases all unused Elastic IPs in all AWS regions."
  echo "It uses the AWS CLI to access AWS resources and requires proper configuration."
  echo ""
  echo "WARNING: Releasing Elastic IPs can have implications for your AWS resources."
  echo "Use this script with caution and understanding."
}

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  print_help
  exit 0
fi

# Require AWS CLI to be installed and configured
if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed or not in PATH."
  exit 1
fi

unused_ips=()

for region in $(aws ec2 describe-regions --output text | cut -f4); do
  echo "Processing region: $region"

  for address in $(aws ec2 describe-addresses --region $region --query 'Addresses[].PublicIp' --output text); do
    if [[ -z $(aws ec2 describe-network-interfaces --filters Name=addresses.private-ip-address,Values=$address --region $region --query 'NetworkInterfaces[].NetworkInterfaceId' --output text) ]]; then
      echo "Found unused Elastic IP: $address"
      aws ec2 release-address --public-ip $address --region $region
      unused_ips+=("$address")
    fi
  done
done

echo "Found and released ${#unused_ips[@]} unused Elastic IPs:"
printf "%s\n" "${unused_ips[@]}"
