
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
