variable "region" {
  type = string
}

variable "managed_organizational_unit" {
  type = string
}

variable "accounts" {
  type = map(object({
    email                     = string
    terraform_state_bucket_id = string
  }))
}

variable "github_organization" {
  type = string
}
