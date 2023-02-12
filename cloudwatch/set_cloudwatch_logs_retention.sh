#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ -z $1 ]]; then
    echo "Error: No argument provided. Usage: ./script.sh <retention>"
    exit 1
fi
