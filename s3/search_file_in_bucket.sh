client=boto3.client('s3')
bucket_name='bucket_name'
prefix=''

s3=boto3.client('s3')

def ListFiles(client, bucket_name, prefix):
    _BUCKET_NAME=bucket_name
    _PREFIX=prefix
    response=client.list_objects(Bucket=_BUCKET_NAME, Prefix=_PREFIX)
    for content in response.get('Contents', []):
        yield content.get('Key')

result=client.list_objects(Bucket=bucket_name, Delimiter='/')
for obj in result.get('CommonPrefixes'):
    prefix=obj.get('Prefix')
