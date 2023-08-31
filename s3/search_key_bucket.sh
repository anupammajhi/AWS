
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
help_document() {
    echo "This script searches for a single keys/object in an S3 bucket and lets you know whether it exists or not."
    echo "Usage: $0"
    exit 0
}

if [[ "$1" == "help" || "$1" == "h" || "$1" == "--help" ]]; then
    help_document
fi

bucket="my-bucket"
key="path/to/my-file.txt"

key_exists() {
    s3=$(aws s3api)
    result=$(s3api head-object --bucket $1 --key $2 2>&1)
    if [[ $result == *"Not Found"* ]]; then
        echo "Key: '$2' does not exist!"
    else
        echo "Key: '$2' found!"
    fi
}

key_exists $bucket $key


