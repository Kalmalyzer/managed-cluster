#!/usr/bin/env bash

set -euo pipefail

TERRAFORM_TFVARS_JSON=$(hcldec --spec=terraform.tfvars.spec terraform.tfvars)

# Template folder
TEMPLATE_DIR="infrastructure/templates"

# Output base folder
OUTPUT_DIR="infrastructure/accounts"

REGION=$(echo $TERRAFORM_TFVARS_JSON | jq -r '.region')
IAM_USERS=$(echo $TERRAFORM_TFVARS_JSON | jq '.iam_users')
IAM_GROUPS=$(echo $TERRAFORM_TFVARS_JSON | jq '.iam_groups')

rm -rf $OUTPUT_DIR/*
# Loop over each account in JSON
for account in $(echo $TERRAFORM_TFVARS_JSON | jq -r '.accounts | keys[]'); do

    # Create output folder for this account
    mkdir -p "$OUTPUT_DIR/$account"

    # Loop over all template files
    for template_file in "$TEMPLATE_DIR"/*; do
        filename=$(basename "${template_file%.jinja2}")
        
        # Extract variables for this account
        # We'll pass only the account-specific data to jinja
        account_data=$(echo $TERRAFORM_TFVARS_JSON | jq -r --arg acc "$account" --arg region $REGION --argjson iam_users "$IAM_USERS" --argjson iam_groups "$IAM_GROUPS" '.accounts[$acc] + {account: $acc} + {region: $region} + {iam_users: $iam_users} + {iam_groups: $iam_groups}')

        # Render template and write to output folder
        echo $account_data | jinja2 -o "$OUTPUT_DIR/$account/$filename" --format json "$template_file" -
    done
done

(echo $TERRAFORM_TFVARS_JSON | jq '{accounts: .accounts | keys}') | jinja2 -o "infrastructure/main.tf" --format json "infrastructure/main.tf.jinja2" -
