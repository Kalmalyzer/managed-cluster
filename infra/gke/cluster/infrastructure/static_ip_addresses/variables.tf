variable "static_global_ip_addresses" {
  type = list(object({
    id = string
  }))
}

variable "static_regional_ip_addresses" {
  type = list(object({
    id     = string
    region = string
  }))
}
