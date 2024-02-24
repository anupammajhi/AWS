#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: ./script.sh"
    exit
fi

aws ec2 describe-key-pairs --query 'KeyPairs[*].[KeyName]' --output text > all_keys.txt
aws ec2 describe-instances --query 'Reservations[*].Instances[*].KeyName' --output text > used_keys.txt

all_keys=$(cat all_keys.txt)
used_keys=$(cat used_keys.txt)

unused_keys=$(comm -23 <(sort all_keys.txt) <(sort used_keys.txt))

echo "All Keys: $(wc -l < all_keys.txt) : $all_keys"
echo "Used Keys: $(wc -l < used_keys.txt) : $used_keys"
echo "Unused Keys: $(wc -l < <(echo "$unused_keys")) : $unused_keys"

