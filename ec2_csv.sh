#!/bin/bash

ROLE_NAME="OrganizationAccountAccessRole"
OUTPUT_DIR="./ec2_inventory"
CSV_FILE="$OUTPUT_DIR/all_ec2_instances.csv"

mkdir -p "$OUTPUT_DIR"
> "$CSV_FILE"

# Write CSV header
echo "AccountId,InstanceId,ImageId,InstanceType,Region" >> "$CSV_FILE"

# Get management account ID
MGMT_ACCOUNT_ID=$(aws organizations describe-organization \
  --query "Organization.MasterAccountId" --output text)

# Get all active non-management accounts
ACCOUNT_IDS=$(aws organizations list-accounts \
  --query "Accounts[?Status=='ACTIVE' && Id!='${MGMT_ACCOUNT_ID}'].Id" \
  --output text)

for ACCOUNT_ID in $ACCOUNT_IDS; do
  echo "Getting EC2 data for account: $ACCOUNT_ID"

  CREDS=$(aws sts assume-role \
    --role-arn "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
    --role-session-name "EC2AuditSession")

  export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

  # Get list of all available regions
  REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

  for REGION in $REGIONS; do
    echo "  Checking region: $REGION"

    aws ec2 describe-instances --region "$REGION" \
      --query "Reservations[*].Instances[*].[InstanceId, ImageId, InstanceType]" \
      --output text | while read INSTANCE_ID IMAGE_ID INSTANCE_TYPE; do
        echo "${ACCOUNT_ID},${INSTANCE_ID},${IMAGE_ID},${INSTANCE_TYPE},${REGION}" >> "$CSV_FILE"
      done
  done

  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done

echo "✅ CSV saved to: $CSV_FILE"
