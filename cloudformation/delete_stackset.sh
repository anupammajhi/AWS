#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

region="us-west-2"
retain_stacks=true

help_document() {
    printf "Usage: %s <stackset_name>\n" "$0"
    exit 0
}

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    help_document
fi

if [ $# -ne 1 ]; then
    printf "Usage: %s <stackset_name>\n" "$0"
    exit 1
fi

stackset_name=$1

response=$(aws cloudformation list-stack-instances --stack-set-name "$stackset_name")

if [ -z "$response" ]; then
    printf "No stack instances found for stackset %s\n" "$stackset_name"
    printf "Proceeding deletion of stackset: %s\n" "$stackset_name"
    aws cloudformation delete-stack-set --stack-set-name "$stackset_name"
    exit
fi
