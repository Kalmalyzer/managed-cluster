variable ssl_certificates {
  type = list(object({
    domains = list(string)
    id = string
  }))
}
