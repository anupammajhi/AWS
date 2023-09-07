
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    echo "Usage: ./search_multiple_keys_bucket.sh"
    exit
fi

function check_keys_exist {
    bucket="my-bucket"
    keys_to_check=("path/to/file1.txt" "path/to/file2.txt" "path/to/file3.txt")

    existing_keys=$(aws s3 ls s3://$bucket --recursive | awk '{print $4}')
    
    for key in "${keys_to_check[@]}"; do
        if [[ " ${existing_keys[@]} " =~ " $key " ]]; then
            exists="true"
        else
