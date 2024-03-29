﻿
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

help_document() {
    echo "This script allows you to create tar file creation."
    echo "Reference question : https://stackoverflow.com/questions/64341192/how-to-create-a-tar-file-containing-all-the-files-in-a-directory/64341789#64341789"
    exit 0
}

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    help_document
fi

agtBucket="angularbuildbucket"
key=""
tar -cf /tmp/example.tar /tmp/

while IFS= read -r fname; do
    echo $fname
    aws s3 cp s3://$agtBucket/$fname /tmp/$fname
    tar -rf /tmp/example.tar /tmp/$fname
done < <(aws s3 ls s3://$agtBucket/$key | awk '{print $4}')

aws s3 cp /tmp/example.tar s3://$agtBucket/example.tar


