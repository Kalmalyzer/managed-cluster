locals {
  namespace                       = "external-secrets"
  kubernetes_service_account_name = "external-secrets"
}

# Create a GCP Service Account, that will be linked to the K8s Service Account with matching name
resource "google_service_account" "cluster_service_account" {
  account_id   = "external-secrets"
  disabled     = false
  display_name = "GCP SA bound to K8S SA ${var.project_id}[${local.namespace}/${local.kubernetes_service_account_name}]"
  project      = var.project_id
}

# Allow the GCP Service Account to be used for Workload Identity by the K8s Service Account
resource "google_service_account_iam_member" "workload_identity_user" {
  member             = "serviceAccount:${var.workload_identity_pool}.svc.id.goog[${local.namespace}/${local.kubernetes_service_account_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.cluster_service_account.id
}
