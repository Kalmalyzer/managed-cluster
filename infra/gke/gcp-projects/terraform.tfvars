project_id = "kalms-managed-gcp-projects"

# Location which the managed cluster will operate in. Choose a location that is near to you.
# Reference: https://cloud.google.com/about/locations
region = "europe-west1"

# Biling account which all newly created projects will get connected to
billing_account = "010A01-78BA4C-BE4C45"

# Create GCP folder with this name; it will contain all managed GCP projects
managed_folder = "kalms-managed-gcp-folder"

projects = {
  # Create a couple of things for each of these:
  # A Google Cloud project
  # A Cloud Storage bucket for Terraform State
  # A Service Account + Workload Identity Pool + Provider for GitHub Actions, with permissions to write to Artifact Registries in the project

  # This project will contain the GKE cluster
  kalms-managed-cluster = {
    terraform_state_bucket_id                = "kalms-managed-cluster-state"
    github_actions_workload_identity_pool_id = "kalms-managed-cluster-gha"
    github_repository                        = "managed-cluster"
  },

  # The projects below are for applications that run on the GKE cluster
  kalms-argocd = {
    terraform_state_bucket_id                = "kalms-argocd-state"
    github_actions_workload_identity_pool_id = "kalms-argocd-gha"
    github_repository                        = "managed-cluster"
  },

  kalms-external-secrets = {
    terraform_state_bucket_id                = "kalms-external-secrets-state"
    github_actions_workload_identity_pool_id = "kalms-external-secrets-gha"
    github_repository                        = "managed-cluster"
  },

  kalms-p4 = {
    terraform_state_bucket_id                = "kalms-p4-state"
    github_actions_workload_identity_pool_id = "kalms-p4-gha"
    github_repository                        = "managed-cluster"
  },
}

# Name of GitHub organization which will contain all repositories
# This will be used for giving GitHub Actions access to Google Cloud projects
github_organization = "kalmalyzer"
