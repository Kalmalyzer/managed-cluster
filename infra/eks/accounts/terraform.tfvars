# Location which the managed cluster will operate in. Choose a location that is near to you.
# Reference: https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html
region = "eu-north-1"

# Organizational Unit which all managed AWS accounts will exist within
managed_organizational_unit = "ou-5s2e-y15u31nq"

accounts = {
  # # Create a couple of things for each of these:
  # # An AWS account

  # This account will contain the EKS cluster
  kalms-managed-cluster = {
    email = "mikael+kalms-managed-cluster@kalms.org"
  },

  # The projects below are for applications that run on the GKE cluster
  kalms-argocd = {
    email = "mikael+kalms-argocd@kalms.org"
  },

  kalms-external-secrets = {
    email = "mikael+kalms-external-secrets@kalms.org"
  },

  kalms-p4 = {
    email = "mikael+kalms-p4@kalms.org"
  },
}
