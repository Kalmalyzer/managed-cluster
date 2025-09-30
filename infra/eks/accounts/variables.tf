variable "region" {
  type = string
}

variable "managed_organizational_unit" {
  type = string
}

variable "accounts" {
  type = map(object({
    email = string
  }))
}
