module "infrastructure" {

  source = "./infrastructure"

  project_id = var.project_id
  region     = var.region
  zones      = var.zones

  cluster_name = var.cluster_name

  kubernetes_cluster_network_config = var.kubernetes_cluster_network_config

  kubernetes_node_pool = var.kubernetes_node_pool

  ssl_certificates = var.ssl_certificates

  static_global_ip_addresses   = var.static_global_ip_addresses
  static_regional_ip_addresses = var.static_regional_ip_addresses

  iap_accessors = var.iap_accessors

  billing_account = var.billing_account
  app_projects = var.app_projects
}
