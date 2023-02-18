
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

