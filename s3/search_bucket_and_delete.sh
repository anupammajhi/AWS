#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
help_function() {
    echo "Usage: $0 <bucket-name>"
    exit 0
}

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    help_function
fi

if [ -z "$1" ]; then
    echo "Please provide the target bucket name as a command line argument"
    exit 1
fi

target_bucket_name=$1
