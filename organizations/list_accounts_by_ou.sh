
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

# Help document function
if [[ $1 == "help" ]] || [[ $1 == "h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: ./script.sh [list of OU names]"
    echo "This script returns a list of accounts that are part of an Organizational Unit (OU)"
    exit
fi

ou_names=("$@")  # Get the list of organizational unit names from command-line arguments

