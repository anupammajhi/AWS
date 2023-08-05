
if [ "$1" = "help" ] || [ "$1" = "h" ] || [ "$1" = "--help" ]; then
    echo "This script allows you to list all files older than N numbers of days."
    echo "Usage: bash script.sh [N]"
    exit 0
fi

client='boto3.client("s3")'
response='client.list_objects(Bucket="angularbuildbucket")'
today_date_time='date +%Y-%m-%d'
for file in response.get("Contents"):
    file_name=file.get("Key")
    modified_time=file.get("LastModified")
