# Location which the managed cluster will operate in. Choose a location that is near to you.
# Reference: https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html
region = "eu-north-1"

# Organizational Unit which all managed AWS accounts will exist within
managed_organizational_unit = "ou-5s2e-y15u31nq"

accounts = {
  # # Create a couple of things for each of these:
  # # An AWS account
  # # A Cloud Storage bucket for Terraform State
  # # A Service Account + Workload Identity Pool + Provider for GitHub Actions, with permissions to write to Artifact Registries in the project

  # This account will contain the EKS cluster
  kalms-managed-cluster = {
    email                     = "mikael+kalms-managed-cluster@kalms.org"
    terraform_state_bucket_id = "kalms-managed-cluster-state"
  },

  # # The projects below are for applications that run on the GKE cluster
  # kalms-argocd = {
  #   terraform_state_bucket_id                = "kalms-argocd-state"
  # },

  # kalms-external-secrets = {
  #   terraform_state_bucket_id                = "kalms-external-secrets-state"
  # },

  # kalms-p4 = {
  #   terraform_state_bucket_id                = "kalms-p4-state"
  # },
}

# Name of GitHub organization which will contain all repositories
# This will be used for giving GitHub Actions access to Google Cloud projects
github_organization = "kalmalyzer"
