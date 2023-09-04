﻿import boto3

client = boto3.client("s3")
bucket_name = "bucket_name"
prefix = ""

result = client.list_objects(Bucket=bucket_name, Delimiter="/")

def ListFiles(client, bucket_name, prefix):
    _BUCKET_NAME = bucket_name
    _PREFIX = prefix
    response = client.list_objects(Bucket=_BUCKET_NAME, Prefix=_PREFIX)

    for content in response.get("Contents", []):
        yield content.get("Key")

for obj in result.get("CommonPrefixes"):
    prefix = obj.get("Prefix")
    file_list = ListFiles(client, bucket_name, prefix)
    for file in file_list:
        if "processed/files" in file:
            print("Found", file)