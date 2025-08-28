# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "static_ip_addresses" {
  for_each = {
    for index, static_ip_address in var.static_regional_ip_addresses :
    static_ip_address.id => static_ip_address
  }

  # Identifier, which other resources use to refer to this IP address
  name = each.value.id

  # IP address is a regional, external address
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#address_type
  address_type = "EXTERNAL"

  # Always IPv4 addresses
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#ip_version
  ip_version = "IPV4"

  # Place address in this region
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#region
  region = each.value.region
}
