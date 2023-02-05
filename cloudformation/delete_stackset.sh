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
