
module "google_apis" {
  source = "./google_apis"
}

module "network" {
  depends_on = [module.google_apis]

  source = "./network"

  project_id                        = var.project_id
  region                            = var.region
  cluster_name                      = var.cluster_name
  kubernetes_cluster_network_config = var.kubernetes_cluster_network_config
}

module "artifact_registries" {
  depends_on = [module.google_apis]

  source = "./artifact_registries"

  project_id = var.project_id
  location   = var.region
}

module "kubernetes_cluster" {
  depends_on = [module.google_apis, module.network]

  source = "./kubernetes_cluster"

  project_id = var.project_id
  region     = var.region
  zones      = var.zones
  cluster_name = var.cluster_name
  network    = module.network.kubernetes_network
  subnetwork = module.network.kubernetes_subnetwork

  ip_range_pods     = module.network.kubernetes_subnetwork_pods_range
  ip_range_services = module.network.kubernetes_subnetwork_services_range

  kubernetes_node_pool = var.kubernetes_node_pool

  container_images_repository_id = module.artifact_registries.container_images_repository_id
}

module "ssl_certificates" {
  depends_on = [module.google_apis]

  source = "./ssl_certificates"

  ssl_certificates = var.ssl_certificates
}

module "static_ip_addresses" {
  depends_on = [module.google_apis]

  source = "./static_ip_addresses"

  static_global_ip_addresses   = var.static_global_ip_addresses
  static_regional_ip_addresses = var.static_regional_ip_addresses
}

module "iap_access" {
  depends_on = [module.google_apis]

  source = "./iap_access"

  project_id = var.project_id
  iap_accessors = var.iap_accessors
}
