project_id = "kalms-managed-gcp-projects"

# Location which the managed cluster will operate in. Choose a location that is near to you.
# Reference: https://cloud.google.com/about/locations
region     = "europe-west1"

# Biling account which all newly created projects will get connected to
billing_account = "010A01-78BA4C-BE4C45"

# Create GCP project with this name; it will contain the GKE cluster
cluster_project = "kalms-managed-cluster"

# Create GCP folder with this name; it will contain the GCP projects for all the apps
app_folder = "kalms-managed-cluster-apps"

app_projects = [
  # Create GCP projects + associated buckets for Terraform state with the following names
  "kalms-external-secrets",
  "kalms-argocd",
]
