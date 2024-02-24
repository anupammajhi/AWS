
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

help_document() {
    echo "Usage: $0 [help|h|--help]"
    exit 1
}

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    help_document
fi

aws lambda invoke --function-name lambda_handler --payload '{"invokingEvent": "{\"messageType\":\"ScheduledNotification\"}"}' /dev/stdout


