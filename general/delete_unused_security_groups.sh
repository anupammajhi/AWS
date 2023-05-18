
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    echo "Usage: $0"
    echo "This script deletes all unused security groups in a single AWS Region"
    exit
fi

aws_profile="default"
region="us-west-1"

used_SG=()

# Find EC2 instances security group in use
response=$(aws ec2 describe-instances --profile $aws_profile --region $region)
for sg in $(echo $response | jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId'); do
    used_SG+=($sg)
done

