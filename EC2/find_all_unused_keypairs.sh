
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0"
  echo "This script finds all used and unused EC2 keypairs in all AWS Regions"
  exit 0
fi

ec2=$(boto3 client ec2)
all_keys=()
used_keys=()
unused_keys=()

for region in $($ec2 describe_regions | jq -r ".Regions[].RegionName"); do
    try
        ec2conn=$(boto3 resource ec2 region_name=$region)
        key_pairs=$($ec2conn key_pairs all)
        all_keys+=( $(for key_pair in $key_pairs; do echo "${key_pair.name} ($region)"; done) )
        used_keys+=( $(for instance in $($ec2conn instances all); do echo $instance.key_name; done) )
    except Exception as e; do
        echo "No access to region $region: $e"
    done
done

unused_keys=( $(comm -23 <(echo "${all_keys[@]}" | tr ' ' '\n' | sort) <(echo "${used_keys[@]}" | sort)) )

echo "All Keys: ${#all_keys[@]} : $(echo "${all_keys[@]}" | sort)"
echo "Used Keys: ${#used_keys[@]} : ${used_keys[@]}"
echo "Unused Keys: ${#unused_keys[@]} : $(echo "${unused_keys[@]}" | sort)"


