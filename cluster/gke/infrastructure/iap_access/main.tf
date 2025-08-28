# Grant the "IAP-secured Web App User" role to the provided members
# This will allow these members to access any IAP-secured backends within the GCP Project
resource "google_project_iam_member" "iap_access" {
    for_each = toset(var.iap_accessors)

    project = var.project_id
    role = "roles/iap.httpsResourceAccessor"
    member = each.key
}
