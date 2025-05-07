#!/bin/bash

# Get the management account ID using describe-organization
management_account=$(aws organizations describe-organization --query "Organization.MasterAccountId" --output text)

# Get all AWS account details (ID and Name) in the organization, excluding the management account
account_details=$(aws organizations list-accounts --query "Accounts[?Id!='${management_account}'].{ID:Id,Name:Name}" --output json)

# Generate a timestamp for the CSV file
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the output CSV file name
output_file="unused_volumes_${timestamp}.csv"

# Create the CSV header
echo "AccountID,AccountName,VolumeID,Size(GB),AvailabilityZone" > "$output_file"

# Iterate over each account and assume role to describe volumes
for row in $(echo "$account_details" | jq -r '.[] | @base64'); do
  # Decode each account's details
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  # Get the account ID and account name
  account_id=$(_jq '.ID')
  account_name=$(_jq '.Name')

  echo "Assuming role in account $account_name ($account_id)"

  # Assume role in the member account using AWSControlTowerExecution
  role_arn="arn:aws:iam::${account_id}:role/AWSControlTowerExecution"
  credentials=$(aws sts assume-role --role-arn "$role_arn" --role-session-name DescribeVolumesSession)

  # Extract temporary credentials from the assumed role response
  access_key=$(echo $credentials | jq -r .Credentials.AccessKeyId)
  secret_key=$(echo $credentials | jq -r .Credentials.SecretAccessKey)
  session_token=$(echo $credentials | jq -r .Credentials.SessionToken)

  # Set temporary AWS credentials
  export AWS_ACCESS_KEY_ID=$access_key
  export AWS_SECRET_ACCESS_KEY=$secret_key
  export AWS_SESSION_TOKEN=$session_token

  # Run the describe-volumes command to find unattached volumes
  echo "Describing unattached volumes in account $account_name ($account_id)"
  volumes=$(aws ec2 describe-volumes --filters Name=status,Values=available --query "Volumes[*].{ID:VolumeId,Size:Size,AZ:AvailabilityZone}" --output text)

  # Loop through volumes and append to the CSV file
  while read -r volume; do
    # Parse the output and format as CSV
    volume_id=$(echo "$volume" | awk '{print $1}')
    size=$(echo "$volume" | awk '{print $2}')
    az=$(echo "$volume" | awk '{print $3}')
    
    # Append the volume information to the CSV file
    echo "$account_id,$account_name,$volume_id,$size,$az" >> "$output_file"
  done <<< "$volumes"

  # Unset AWS credentials to avoid conflicts
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done

echo "CSV export completed: $output_file"
