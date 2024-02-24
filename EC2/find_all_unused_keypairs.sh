#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0"
  echo "This script finds all used and unused EC2 keypairs in all AWS Regions"
  exit 0
fi

all_keys=()
used_keys=()
unused_keys=()

for region in $(aws ec2 describe-regions --query "Regions[].{Name:RegionName}" --output text); do
    key_pairs=$(aws ec2 describe-key-pairs --region $region --query 'KeyPairs[].KeyName' --output text)
    all_keys+=($key_pairs)
    instances=$(aws ec2 describe-instances --region $region --query 'Reservations[].Instances[].KeyName' --output text)
    used_keys+=($instances)
done

echo "${all_keys[@]}" | tr ' ' '\n' | sort > all_keys.txt
echo "${used_keys[@]}" | tr ' ' '\n' | sort > used_keys.txt

unused_keys=( $(comm -23 all_keys.txt used_keys.txt) )

echo "All Keys: ${#all_keys[@]} : $(sort -u all_keys.txt)"
echo "Used Keys: ${#used_keys[@]} : ${used_keys[@]}"
echo "Unused Keys: ${#unused_keys[@]} : $(sort -u <<< "${unused_keys[*]}")"