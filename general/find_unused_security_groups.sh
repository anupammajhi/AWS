
if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0"
    echo "This script finds all unused security groups in a single AWS Region"
    exit
fi

ec2=$(aws ec2 describe-instances)
elb=$(aws elb describe-load-balancers)
elbv2=$(aws elbv2 describe-load-balancers)
rds=$(aws rds describe-db-instances)

used_SG=()

for instance in $(echo "$ec2" | jq -r '.Reservations[].Instances[]'); do
    for sg in $(echo "$instance" | jq -r '.SecurityGroups[].GroupId'); do
        used_SG+=("$sg")
    done
done

for lb in $(echo "$elb" | jq -r '.LoadBalancerDescriptions[].SecurityGroups[]'); do
    used_SG+=("$lb")
done

for lb in $(echo "$elbv2" | jq -r '.LoadBalancers[].SecurityGroups[]'); do
    used_SG+=("$lb")
done

for instance in $(echo "$rds" | jq -r '.DBInstances[]'); do
    for sg in $(echo "$instance" | jq -r '.VpcSecurityGroups[].VpcSecurityGroupId'); do
        used_SG+=("$sg")
    done
done

response=$(aws ec2 describe-security-groups)
total_SG=($(echo "$response" | jq -r '.SecurityGroups[].GroupId'))
unused_SG=()

for sg in "${total_SG[@]}"; do
    if [[ ! " ${used_SG[@]} " =~ " $sg " ]]; then
        unused_SG+=("$sg")
    fi
done

echo "Total Security Groups: ${#total_SG[@]}"
echo "Used Security Groups: ${#used_SG[@]}"
echo "Unused Security Groups: ${#unused_SG[@]} compiled in the following list:"
echo "${unused_SG[@]}"


