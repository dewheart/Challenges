#!/bin/bash

# ==== CONFIGURATION ====
ROLE_NAME="OrganizationAccountAccessRole"
OUTPUT_DIR="./ec2_inventory"
CSV_FILE="$OUTPUT_DIR/all_ec2_instances.csv"
REGION="us-east-1"

# ==== PREP ====
mkdir -p "$OUTPUT_DIR"
> "$CSV_FILE"

# CSV header
echo "AccountId,AccountName,Region,InstanceId,InstanceName,ImageId,ImageName,InstanceType,PlatformDetails,State,LaunchTime,AvailabilityZone,PrivateIpAddress,PublicIpAddress,VpcId,SubnetId" >> "$CSV_FILE"

# Get management account ID
MGMT_ACCOUNT_ID=$(aws organizations describe-organization \
  --query "Organization.MasterAccountId" --output text)

# Get all active member accounts (excluding management account)
ACCOUNTS=$(aws organizations list-accounts \
  --query "Accounts[?Status=='ACTIVE' && Id!='${MGMT_ACCOUNT_ID}'].[Id,Name]" \
  --output text)

# ==== MAIN LOOP ====
while read -r ACCOUNT_ID ACCOUNT_NAME; do
  echo "🔄 Assuming role in account: $ACCOUNT_NAME ($ACCOUNT_ID)"

  CREDS=$(aws sts assume-role \
    --role-arn "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
    --role-session-name "EC2InventorySession")

  export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

  echo "  🔍 Scanning region: $REGION"

  INSTANCES=$(aws ec2 describe-instances --region "$REGION" --output json)

  echo "$INSTANCES" | jq -c '.Reservations[].Instances[]' | while read -r instance; do
    INSTANCE_ID=$(echo "$instance" | jq -r '.InstanceId')
    IMAGE_ID=$(echo "$instance" | jq -r '.ImageId')
    INSTANCE_NAME=$(echo "$instance" | jq -r '.Tags[]? | select(.Key=="Name") | .Value // "N/A"')
    INSTANCE_TYPE=$(echo "$instance" | jq -r '.InstanceType')
    PLATFORM_DETAILS=$(echo "$instance" | jq -r '.PlatformDetails')
    STATE=$(echo "$instance" | jq -r '.State.Name')
    LAUNCH_TIME=$(echo "$instance" | jq -r '.LaunchTime')
    AVAILABILITY_ZONE=$(echo "$instance" | jq -r '.Placement.AvailabilityZone')
    PRIVATE_IP=$(echo "$instance" | jq -r '.PrivateIpAddress // "N/A"')
    PUBLIC_IP=$(echo "$instance" | jq -r '.PublicIpAddress // "N/A"')
    VPC_ID=$(echo "$instance" | jq -r '.VpcId // "N/A"')
    SUBNET_ID=$(echo "$instance" | jq -r '.SubnetId // "N/A"')

    # Try to resolve AMI name
    IMAGE_NAME=$(aws ec2 describe-images --region "$REGION" --image-ids "$IMAGE_ID" \
      --query "Images[0].Name" --output text 2>/dev/null)
    [[ $? -ne 0 || "$IMAGE_NAME" == "None" ]] && IMAGE_NAME="N/A"

    # Write to CSV
    echo "\"$ACCOUNT_ID\",\"$ACCOUNT_NAME\",\"$REGION\",\"$INSTANCE_ID\",\"$INSTANCE_NAME\",\"$IMAGE_ID\",\"$IMAGE_NAME\",\"$INSTANCE_TYPE\",\"$PLATFORM_DETAILS\",\"$STATE\",\"$LAUNCH_TIME\",\"$AVAILABILITY_ZONE\",\"$PRIVATE_IP\",\"$PUBLIC_IP\",\"$VPC_ID\",\"$SUBNET_ID\"" >> "$CSV_FILE"
  done

  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done <<< "$ACCOUNTS"

echo "✅ EC2 inventory complete. CSV saved to: $CSV_FILE"