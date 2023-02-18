﻿
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: bash script.sh [options]"
    exit 0
fi

ACCOUNT_DESC="$ACCOUNT_DESC" 
SLACK_URL="$SLACK_URL" 
SLACK_CHANNEL="$SLACK_CHANNEL" 
ALWAYS_SHOW_SUCCEEDED="$ALWAYS_SHOW_SUCCEEDED"

get_previous_pipeline_execution() {
    pipeline_executions=$(aws codepipeline list-pipeline-executions --pipeline-name $1 | jq '.pipelineExecutionSummaries')

    is_next=false

    for item in $pipeline_executions; do
        status=$(echo $item | jq -r '.status')
        if $is_next && ([ "$status" == "Succeeded" ] || [ "$status" == "Failed" ]); then
            echo $item
            return
        fi
        pipelineExecutionId=$(echo $item | jq -r '.pipelineExecutionId')
        if [ "$pipelineExecutionId" == "$2" ]; then
            is_next=true
        fi

        # Use environment variables directly
        ACCOUNT_DESC="$ACCOUNT_DESC"
        SLACK_URL="$SLACK_URL"
        SLACK_CHANNEL="$SLACK_CHANNEL"
        ALWAYS_SHOW_SUCCEEDED="$ALWAYS_SHOW_SUCCEEDED"
        if $is_next && ([ "$status" == "Succeeded" ] || [ "$status" == "Failed" ]); then
            echo $item
            return
        fi
        if [ "$(echo $item | jq -r '.pipelineExecutionId')" == "$2" ]; then
            is_next=true
        fi
    done

    echo "null"
}

get_blocks_for_failed() {
    if [ "$3" != "FAILED" ]; then
        echo "[]"
        return
