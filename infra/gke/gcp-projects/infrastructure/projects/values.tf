output "github_actions_auth_settings" {
  value = {
    for project, project_value in var.projects :
    project => {
      service_account            = google_service_account.github_actions[project].email
      workload_identity_provider = google_iam_workload_identity_pool_provider.github_actions[project].name
    }
  }
}
