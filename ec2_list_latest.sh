#!/bin/bash

ROLE_NAME="OrganizationAccountAccessRole"

# Get management (root) account ID
MGMT_ACCOUNT_ID=$(aws organizations describe-organization \
  --query "Organization.MasterAccountId" --output text)

# Get list of all ACTIVE account IDs, excluding the management account
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

  aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].{AccountId:\"$ACCOUNT_ID\", InstanceId:InstanceId, ImageId:ImageId}" \
    --output table

  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done
