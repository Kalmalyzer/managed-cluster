resource "google_compute_managed_ssl_certificate" "ssl_certificates" {
  for_each = {
    for index, ssl_certificate in var.ssl_certificates:
      ssl_certificate.id => ssl_certificate
  }

  name = each.value.id

  managed {
    domains = each.value.domains
  }
}
