
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
