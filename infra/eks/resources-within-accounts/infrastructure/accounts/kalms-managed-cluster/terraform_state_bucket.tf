# Create an S3 bucket within each of the listed accounts
# The buckets are intended to contain Terraform state
# Each individual account can then have a Terraform stack that expects the account + state bucket to already exist

# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "account_state" {

  provider = aws.kalms-managed-cluster

  # Bucket name
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#bucket-1
  bucket = "kalms-managed-cluster-state"

  # Attempts to delete the bucket will fail if the bucket contains any objects
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#force_destroy-1
  force_destroy = false
}
