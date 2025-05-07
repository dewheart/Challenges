#!/bin/bash

ROLE_NAME="OrganizationAccountAccessRole"
REGION="us-east-1"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
CSV_FILE="unused_ebs_volumes_$TIMESTAMP.csv"

# Auto-detect management account ID
MANAGEMENT_ACCOUNT_ID=$(aws organizations describe-organization \
  --query 'Organization.MasterAccountId' --output text)

echo "Detected management account ID: $MANAGEMENT_ACCOUNT_ID"

# Create header in CSV
echo "AccountID,AccountName,VolumeID,Size(GB),AvailabilityZone,CreateTime" > "$CSV_FILE"

# Create associative array AccountID -> AccountName
declare -A ACCOUNT_MAP

while read -r id name; do
  ACCOUNT_MAP["$id"]="$name"
done < <(aws organizations list-accounts \
  --query "Accounts[?Id!='${MANAGEMENT_ACCOUNT_ID}'].[Id,Name]" \
  --output text)

# Loop through accounts
for ACCOUNT_ID in "${!ACCOUNT_MAP[@]}"; do
  ACCOUNT_NAME="${ACCOUNT_MAP[$ACCOUNT_ID]}"
  echo "Checking account: $ACCOUNT_NAME ($ACCOUNT_ID)"

  # Assume role
  CREDS=$(aws sts assume-role \
    --role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME} \
    --role-session-name "CheckUnusedVolumesSession")

  export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

  # Get unused volumes
  VOLUMES=$(aws ec2 describe-volumes \
    --region "$REGION" \
    --filters Name=status,Values=available \
    --query "Volumes[*].[VolumeId,Size,AvailabilityZone,CreateTime]" \
    --output text)

  while read -r vol_id size az ctime; do
    echo "$ACCOUNT_ID,\"$ACCOUNT_NAME\",$vol_id,$size,$az,$ctime" >> "$CSV_FILE"
  done <<< "$VOLUMES"

  echo "Done with $ACCOUNT_NAME"
  echo "-----------------------------"
done

# Clean up
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

echo "✅ Results saved to: $CSV_FILE"
