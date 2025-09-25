variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "managed_folder" {
  type = string
}

variable "projects" {
  type = map(object({
    terraform_state_bucket_id                = string
    github_actions_workload_identity_pool_id = string
    github_repository                        = string
  }))
}

variable "github_organization" {
  type = string
}
