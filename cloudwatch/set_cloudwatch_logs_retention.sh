#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [[ -z $1 ]]; then
    echo "Error: No argument provided. Usage: ./script.sh <retention>"
    exit 1
fi

allowed_values=(1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653)
if [[ ! "${allowed_values[@]}" =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    echo "Invalid retention value. Please choose one of the allowed values: ${allowed_values[@]}"
    exit 1
fi
