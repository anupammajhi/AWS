#!/usr/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# ------------------------------------------------
# Command help information
# ------------------------------------------------
display_help() {
  echo "A ssh wrapper for connecting quickly to EC2 instances in an Auto Scaling group."
  echo ""
  echo "Usage: ssh_autoscalinggroup {ssh-key-location} {ssh-user}"
  echo "eg: ssh_autoscalinggroup foobar ~/app/app.pem root"
  echo ""
  echo "Note: Make sure to export the AWS profile first, read more:"
  echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html"
}

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  display_help
  exit
fi

# ------------------------------------------------
# Fetch autoscaling groups
# ------------------------------------------------
AUTO_SCALINGS=$(aws autoscaling describe-auto-scaling-groups --output json)
# Auto scaling names
AUTO_SCALING_IDS=$(echo $AUTO_SCALINGS | jq -r '.AutoScalingGroups[].AutoScalingGroupName')
FILTERED_AUTO_SCALING_IDS=$(echo $AUTO_SCALING_IDS | tr ' ' '\n' | sort -u | tr '\n' ' ')

# Apply filter
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/True/}")
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/False/}")
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/Healthy/}")
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/Unhealthy/}")
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/UnHealthy/}")
FILTERED_AUTO_SCALING_IDS=("${FILTERED_AUTO_SCALING_IDS[@]/True/}")

PS3='Select auto scaling group: '
select AUTO_SCALING_ID in $FILTERED_AUTO_SCALING_IDS 'Quit'; do
  if [ "$AUTO_SCALING_ID" = "Quit" ]; then
    exit
  else
    echo "Selected: $AUTO_SCALING_ID"
    break
  fi
done

# ------------------------------------------------
# Fetch running instances within autoscaling group
# ------------------------------------------------
INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AUTO_SCALING_ID --query 'AutoScalingGroups[0].Instances[]' --output json)
# Collect instance ids
INSTANCE_IDS=$(echo $INSTANCES | jq -r '.[].InstanceId')

PS3='Select instance: '
select INSTANCE_ID in $INSTANCE_IDS 'Quit'; do
  if [ "$INSTANCE_ID" = "Quit" ]; then
    exit
  else
    echo "Selected: $INSTANCE_ID"
    break
  fi
done

# ------------------------------------------------
# Setup SSH user
# ------------------------------------------------
SSH_USER='ec2-user'
if [[ -n "$3" ]]; then
  SSH_USER=$3
fi

# ------------------------------------------------
# Get instance IP and SSH into instance
# ------------------------------------------------
# Fetch instance ip
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

if [ "$PUBLIC_IP" != "None" ]; then
  if [ -r "$2" ]; then
    echo "SSHing into public instance: $PUBLIC_IP with user $SSH_USER"
    ssh -i $2 $SSH_USER@$PUBLIC_IP
    break
  else
    echo "SSH key file $2 does not exist or is not readable"
    break
  fi
else
  if [ -r "$2" ]; then
    echo "SSHing into private instance: $PRIVATE_IP with user $SSH_USER"
    ssh -i $2 $SSH_USER@$PRIVATE_IP
    break
  else
    echo "SSH key file $2 does not exist or is not readable"
    break
  fi
fi