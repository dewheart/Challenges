#!/bin/bash

# ==== CONFIGURATION ====
ROLE_NAME="OrganizationAccountAccessRole"
OUTPUT_DIR="./ec2_inventory"
CSV_FILE="$OUTPUT_DIR/all_ec2_instances.csv"
REGION="us-east-1"

# ==== PREP ====
mkdir -p "$OUTPUT_DIR"
> "$CSV_FILE"

# Write CSV header
echo "AccountId,Region,InstanceId,InstanceName,ImageId,InstanceType,PlatformDetails,State,AvailabilityZone,PrivateIpAddress,PublicIpAddress,VpcId,SubnetId" >> "$CSV_FILE"

# Get management account ID
MGMT_ACCOUNT_ID=$(aws organizations describe-organization \
  --query "Organization.MasterAccountId" --output text)

# Get all active member accounts (excluding management account)
ACCOUNT_IDS=$(aws organizations list-accounts \
  --query "Accounts[?Status=='ACTIVE' && Id!='${MGMT_ACCOUNT_ID}'].Id" \
  --output text)

# ==== MAIN LOOP ====
for ACCOUNT_ID in $ACCOUNT_IDS; do
  echo "🔄 Assuming role in account: $ACCOUNT_ID"

  CREDS=$(aws sts assume-role \
    --role-arn "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
    --role-session-name "EC2InventorySession")

  export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

  echo "  🔍 Scanning region: $REGION"

  INSTANCES=$(aws ec2 describe-instances --region "$REGION" \
    --query 'Reservations[*].Instances[*]' \
    --output json)

  echo "$INSTANCES" | jq -r --arg account "$ACCOUNT_ID" --arg region "$REGION" '
    .[][] | [
      $account,
      $region,
      .InstanceId,
      (.Tags[]? | select(.Key == "Name") | .Value) // "N/A",
      .ImageId,
      .InstanceType,
      .PlatformDetails,
      .State.Name,
      .Placement.AvailabilityZone,
      .PrivateIpAddress // "N/A",
      .PublicIpAddress // "N/A",
      .VpcId,
      .SubnetId
    ] | @csv
  ' >> "$CSV_FILE"

  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done

echo "✅ Inventory complete. CSV saved to: $CSV_FILE"