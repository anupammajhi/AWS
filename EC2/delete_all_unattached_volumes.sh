#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

count=0

for region in $(aws ec2 describe-regions --output text --query 'Regions[*].RegionName'); do
  echo "Processing region $region..."

  aws ec2 describe-volumes --region $region --output text --query 'Volumes[*].{Attachments:Attachments,VolumeId:VolumeId}' | \
