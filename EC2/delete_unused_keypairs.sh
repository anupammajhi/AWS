import argparse
import boto3

def delete_unused_key_pairs():
    ec2 = boto3.resource("ec2")
    key_pairs = ec2.key_pairs.all()

    used_keys = set([instance.key_name for instance in ec2.instances.all()])
    unused_keys = [
        key_pair.name for key_pair in key_pairs if key_pair.name not in used_keys
    ]

    for key_name in unused_keys:
        ec2.KeyPair(key_name).delete()

    print(f"Deleted {len(unused_keys)} unused key pairs.")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ['help', 'h', '--help']:
        print("Help document goes here")
        exit()

    delete_unused_key_pairs()

