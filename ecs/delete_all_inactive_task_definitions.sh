
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
    client=boto3.client("ecs", region_name="$1")
    arns=()
    paginator=client.get_paginator("list_task_definitions")
    for page in paginator.paginate(status="INACTIVE"); do
        arns+=($(echo $page | jq -r '.taskDefinitionArns[]'))
    done
    echo "${arns[@]}"
}

delete_task_definition() {
    client=boto3.client("ecs", region_name="$1")
    max_retries=5
    backoff=1
    for attempt in $(seq 1 $max_retries); do
        client.delete_task_definitions(taskDefinitions="$2")
        echo "Deleted task definition $2"
        break
    done
}

delete_inactive_task_definitions_in_region() {
    arns=($(get_inactive_task_definition_arns "$1"))
    if [ ${#arns[@]} -eq 0 ]; then
        echo "No inactive task definitions found in region $1"
