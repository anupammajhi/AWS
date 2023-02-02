#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

count=0

for region in $(aws ec2 describe-regions --output text --query 'Regions[*].RegionName'); do
  echo "Processing region $region..."

  aws ec2 describe-volumes --region $region --output text --query 'Volumes[*].{Attachments:Attachments,VolumeId:VolumeId}' | \
  while read -r attachments volume_id; do
    if [[ -z "$attachments" ]]; then
      echo "Deleting unattached volume $volume_id in region $region..."
      aws ec2 delete-volume --volume-id $volume_id --region $region
      count=$((count+1))
    else
      echo "Volume $volume_id is attached in region $region, skipping."
    fi
  done
done

