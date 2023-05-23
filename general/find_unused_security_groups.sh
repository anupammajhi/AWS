
if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0"
    echo "This script finds all unused security groups in a single AWS Region"
    exit
fi

ec2=$(aws ec2 describe-instances)
elb=$(aws elb describe-load-balancers)
elbv2=$(aws elbv2 describe-load-balancers)
rds=$(aws rds describe-db-instances)
