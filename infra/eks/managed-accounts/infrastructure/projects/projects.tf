
# Create an AWS account for each of the listed accounts

# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account
resource "aws_organizations_account" "account" {

  for_each = var.accounts

  # Friendly name for account
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#name-1
  name = each.key

  # Email address for account owner
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#email-1
  email = each.value.email

  # Parent Organizational Unit ID (in theory this could be the Root ID as well, but we expect the project to be created within an OU)
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#parent_id-1
  parent_id = var.managed_organizational_unit

  # When deleting the Terraform resource, don't close the AWS account
  # This effectively means that the account gets orphaned
  # To close/delete the actual AWS account, you (the operator) needs to deal with AWS directly
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#close_on_deletion-1
  close_on_deletion = false

  # Disallow IAM users access to billing information within this account
  # Since we use an AWS Organization, all billing is consolidated into the management account (so there is no billing information within this account)
  # Therefore, there is no point in IAM Users having access to billing information within this account
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#iam_user_access_to_billing-1
  iam_user_access_to_billing = "DENY"
}
