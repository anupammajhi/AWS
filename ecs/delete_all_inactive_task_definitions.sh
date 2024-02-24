#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

help_document() {
    echo "Usage: $0 [region]"
    echo "If region is not provided, it will delete inactive task definitions in all AWS regions."
    exit 1
}

if [[ $1 == "help" || $1 == "h" || $1 == "--help" ]]; then
    help_document
fi

get_inactive_task_definition_arns() {
    aws ecs list-task-definitions --status INACTIVE --region "$1" | jq -r '.taskDefinitionArns[]'
}

delete_task_definition() {
    aws ecs deregister-task-definition --task-definition "$2" --region "$1"
    echo "Deleted task definition $2"
}

delete_inactive_task_definitions_in_region() {
    arns=$(get_inactive_task_definition_arns "$1")
    if [ -z "$arns" ]; then
        echo "No inactive task definitions found in region $1"
    else
        for arn in $arns; do
            delete_task_definition "$1" "$arn"
        done
    fi
}

delete_inactive_task_definitions_in_all_regions() {
    ecs_regions=$(aws ec2 describe-regions --output text | cut -f3)
    for region in $ecs_regions; do
        delete_inactive_task_definitions_in_region "$region"
    done
}

if [ $# -gt 1 ]; then
    help_document
elif [ $# -eq 1 ]; then
    delete_inactive_task_definitions_in_region "$1"
else
    delete_inactive_task_definitions_in_all_regions
fi