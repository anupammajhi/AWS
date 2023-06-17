
#!/bin/bash
## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS

if [ "$1" == "help" ] || [ "$1" == "h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 [username]"
    exit 1
fi

username=$1

delete_access_keys() {
    response=$(aws iam list-access-keys --user-name $username)
    for access_key in $(echo $response | jq -r ".AccessKeyMetadata[] | .AccessKeyId"); do
        aws iam delete-access-key --user-name $username --access-key-id $access_key
    done
}

delete_signing_certificates() {
    response=$(aws iam list-signing-certificates --user-name $username)
    for certificate_id in $(echo $response | jq -r ".Certificates[] | .CertificateId"); do
        aws iam delete-signing-certificate --user-name $username --certificate-id $certificate_id
    done
}

delete_login_profile() {
    aws iam delete-login-profile --user-name $username &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Login profile deleted."
    else
        echo "No login profile found."
    fi
}

delete_mfa_devices() {
    response=$(aws iam list-mfa-devices --user-name $username)
    for serial_number in $(echo $response | jq -r ".MFADevices[] | .SerialNumber"); do
        aws iam deactivate-mfa-device --user-name $username --serial-number $serial_number
    done
}

delete_access_keys
delete_signing_certificates
