module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = var.cluster_name
  project = var.project_id
  network = google_compute_network.kubernetes.name
  region  = var.region

  # Set up Cloud NAT that allows all services within the GKE cluster to reach the Internet

  nats = [{
    name = "${var.cluster_name}-to-internet"

    # Let GCP allocate the necessary IP addresses
    # Reference: https://cloud.google.com/nat/docs/public-nat
    # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#nat_ip_allocate_option
    nat_ip_allocate_option = "AUTO_ONLY"

    # Explicitly specify that the GKE cluster-related IP ranges, and no others, should be allowed to NAT
    # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#source_subnetwork_ip_ranges_to_nat
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
        name                     = google_compute_subnetwork.kubernetes.name
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = google_compute_subnetwork.kubernetes.secondary_ip_range[*].range_name
      }
    ]
  }]
}
