locals {
  kubernetes_network    = "${var.cluster_name}-network"
  kubernetes_subnetwork = "${var.cluster_name}-subnetwork"

  kubernetes_subnetwork_pods_range     = "${var.cluster_name}-subnetwork-pods"
  kubernetes_subnetwork_services_range = "${var.cluster_name}-subnetwork-services"
}

resource "google_compute_network" "kubernetes" {

  name                    = local.kubernetes_network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kubernetes" {

  name          = local.kubernetes_subnetwork
  ip_cidr_range = var.kubernetes_cluster_network_config.vms_cidr_range
  region        = var.region
  network       = google_compute_network.kubernetes.id

  # Allow VMs in this subnetwork without public IPs to access Google APIs and services via Private Google Access
  # Reference: https://cloud.google.com/vpc/docs/private-google-access
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#private_ip_google_access
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.kubernetes_subnetwork_pods_range
    ip_cidr_range = var.kubernetes_cluster_network_config.pods_cidr_range
  }

  secondary_ip_range {
    range_name    = local.kubernetes_subnetwork_services_range
    ip_cidr_range = var.kubernetes_cluster_network_config.services_cidr_range
  }
}
