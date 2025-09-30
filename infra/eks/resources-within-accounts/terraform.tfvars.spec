# This specification is used to parse "terraform.tfvars" into JSON

object {
  attr "region" {
    type = string
  }

  attr "accounts" {
    type = map(object({
      terraform_state_bucket_id = string
    }))
  }

  attr "github_organization" {
    type = string
  }
}
