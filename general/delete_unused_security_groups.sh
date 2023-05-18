
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

# Find Classic load balancer security group in use
response=$(aws elb describe-load-balancers --profile $aws_profile --region $region)
for sg in $(echo $response | jq -r '.LoadBalancerDescriptions[].SecurityGroups[]'); do
    used_SG+=($sg)
done

# Find Application load balancer security group in use
response=$(aws elbv2 describe-load-balancers --profile $aws_profile --region $region)
for sg in $(echo $response | jq -r '.LoadBalancers[].SecurityGroups[]'); do
    used_SG+=($sg)
done

# Find RDS db security group in use
response=$(aws rds describe-db-instances --profile $aws_profile --region $region)
for sg in $(echo $response | jq -r '.DBInstances[].VpcSecurityGroups[].VpcSecurityGroupId'); do
    used_SG+=($sg)
done

total_SG=($(aws ec2 describe-security-groups --profile $aws_profile --region $region | jq -r '.SecurityGroups[].GroupId'))
unused_SG=()

for sg in "${total_SG[@]}"; do
    if [[ ! " ${used_SG[@]} " =~ " $sg " ]]; then
        unused_SG+=($sg)
    fi
done

echo "Total Security Groups: ${#total_SG[@]}"
echo "Used Security Groups: ${#used_SG[@]}"
echo
echo "Unused Security Groups: ${#unused_SG[@]} compiled in the following list:"
echo "${unused_SG[@]}"
echo

# Delete unused security groups, except those containing "default" in the name
for sg_id in "${unused_SG[@]}"; do
    sg_name=$(aws ec2 describe-security-groups --group-ids $sg_id --profile $aws_profile --region $region | jq -r '.SecurityGroups[0].GroupName')

    if [[ $sg_name == *"default"* ]]; then
