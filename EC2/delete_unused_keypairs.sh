#!/bin/bash

delete_unused_key_pairs() {
    echo "Checking for unused EC2 key pairs..."

    # Get a list of all key pairs
    key_pairs=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text)

    # Get a list of all used key names
    used_keys=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].KeyName' --output text)

    # Loop through all key pairs, delete if not used
    unused_keys=()
    for key_name in $key_pairs; do
        if ! grep -q "$key_name" <<< "$used_keys"; then
            unused_keys+=("$key_name")
            aws ec2 delete-key-pair --key-name "$key_name"
        fi
    done

    num_deleted=${#unused_keys[@]}
    echo "Deleted $num_deleted unused key pairs."
}

if [[ $# -gt 0 && ($1 == "--help" || $1 == "help" || $1 == "-h") ]]; then
    echo "Usage: $0 [OPTION]"
    echo "Deletes unused EC2 key pairs."
    echo
    echo "Options:"
    echo "  --help, -h    display this help and exit"
}
fi

delete_unused_key_pairs
