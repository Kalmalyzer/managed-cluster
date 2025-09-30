variable "region" {
  type = string
}

variable "accounts" {
  type = map(object({
    terraform_state_bucket_id = string
  }))
}

variable "github_organization" {
  type = string
}
