locals {
  namespace = "argocd"

  accounts = ["argocd-server", "argocd-application-controller"]
}

# Create a GCP Service Account, that will be linked to the K8s Service Account with matching name
resource "google_service_account" "cluster_service_account" {
  for_each = toset(local.accounts)

  account_id   = each.key
  disabled     = false
  display_name = "GCP SA bound to K8S SA ${var.project_id}[${local.namespace}/${each.key}]"
  project      = var.project_id
}

# Allow the GCP Service Account to be used for Workload Identity by the K8s Service Account
resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = toset(local.accounts)

  member             = "serviceAccount:${var.workload_identity_pool}.svc.id.goog[${local.namespace}/${each.key}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.cluster_service_account[each.key].id
}
