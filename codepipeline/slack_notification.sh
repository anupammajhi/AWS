
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
    fi

    action_executions=$(aws codepipeline list-action-executions --pipeline-name $1 --filter pipelineExecutionId=$2 | jq '.actionExecutionDetails')

    result=()

    for action_execution in $action_executions; do
        status=$(echo $action_execution | jq -r '.status')
        if [ "$status" == "Failed" ]; then
            stage=$(echo $action_execution | jq -r '.stageName')
            action=$(echo $action_execution | jq -r '.actionName')
            summary=$(echo $action_execution | jq -r '.output.executionResult.externalExecutionSummary')
            result+=("{\"type\": \"section\",\"text\": {\"type\": \"mrkdwn\",\"text\": \"${stage}.${action} failed:\\n\\`${summary}\\n\\`\"}}")
        fi
    done

    echo "${result[@]}"
}

handler() {
    event=$1
    account="${event["account"]}"
    region="${event["region"]}"
    pipeline_name="${event["detail"]["pipeline"]}"
    state="${event["detail"]["state"]}"
    execution_id="${event["detail"]["execution-id"]}"

    previous_pipeline_execution=$(get_previous_pipeline_execution $pipeline_name $execution_id)

    previous_failed=false
    if [ "$previous_pipeline_execution" != "null" ] && [ "$(echo $previous_pipeline_execution | jq -r '.status')" == "Failed" ]; then
        previous_failed=true
    fi

    if [ "$state" == "SUCCEEDED" ] && [ "$ALWAYS_SHOW_SUCCEEDED" == "false" ] && [ "$previous_pipeline_execution" != "null" ] && [ "$previous_failed" == false ]; then
        echo "Ignoring succeeded event"
        return
    fi

    emoji_prefix=""
    if [ "$state" == "FAILED" ]; then
        emoji_prefix=":x: "
    elif [ "$state" == "SUCCEEDED" ]; then
        emoji_prefix=":white_check_mark: "
    fi

    pipeline_url="https://${region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/$(echo $pipeline_name | jq -r @uri)/view"
    execution_url="https://${region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/$(echo $pipeline_name | jq -r @uri)/executions/${execution_id}/timeline"

    state_text="$state"
    if [ "$previous_failed" == true ] && [ "$state" == "SUCCEEDED" ]; then
        state_text="${state_text} (previously failed)"
