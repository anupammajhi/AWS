
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
    difference_days=$(( ( $(date +%s) - $(date -d "$modified_time" +%s) ) / (60*60*24) ))
    if [ $difference_days -gt 60 ]; then
        echo "file more than 60 days older : - $file_name"
    fi
done


