
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
