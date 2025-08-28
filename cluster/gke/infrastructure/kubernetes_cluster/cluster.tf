module "gke" {
  # TODO: Convert the cluster into a 100% private cluster
  # This involves setting enable_private_endpoint, and establishing ways in which
  #   external operations (such as kubectl from a workstation) still can reach the
  #   cluster when necessary; perhaps a bastion host approach as
  #   described here: https://cloud.google.com/kubernetes-engine/docs/tutorials/private-cluster-bastion
  # It is however not trivial to retain ease of use
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept

  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "38.0.1"

  project_id = var.project_id
  name       = var.cluster_name

  # Allow deleting cluster
  deletion_protection = false

  # The cluster is regional (as opposed to multi-zonal or zonal)
  regional = true

  # The region to host the cluster in
  region = var.region

  # The zones to host the cluster in
  zones = var.zones

  # The VPC network to host the cluster in
  network = var.network

  # The subnetwork to host the cluster in
  subnetwork = var.subnetwork

  # Name of secondary subnet ip range to use for pods
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips#cluster_sizing
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#cluster_secondary_range_name
  ip_range_pods = var.ip_range_pods

  # Name of secondary subnet ip range to use for services
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips#cluster_sizing
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#services_secondary_range_name
  ip_range_services = var.ip_range_services

  # Enable GKE Ingress for Application Load Balancers
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/ingress
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#http_load_balancing
  http_load_balancing = true

  # Enable Horizontal Pod Autoscaler
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/horizontalpodautoscaler
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#horizontal_pod_autoscaling
  horizontal_pod_autoscaling = true

  # We use Dataplane V2, which comes with network policy enforcement built-in. Explicitly enabling the network
  #   policy would fail for our cluster. Therefore we leave the setting disabled.
  # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/dataplane-v2#create-cluster
  network_policy = false

  # There is a default node pool called "default-pool"; it is created along with the cluster; delete that node pool please
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#remove_default_node_pool
  remove_default_node_pool = true

  # Enable Gateway API
  # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways#create-cluster-gateway
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#gateway_api_config
  gateway_api_channel = "CHANNEL_STANDARD"

  # Enable Dataplane V2
  # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/dataplane-v2#create-cluster
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#datapath_provider
  datapath_provider = "ADVANCED_DATAPATH"

  # Provision both internal and external IP for the control plane
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept#architecture_of_private_clusters
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#enable_private_endpoint
  enable_private_endpoint = false

  # Google's GKE management services, and the cluster's own nodes/pods/services
  #   will always be able to reach the control plane
  # Do not provide a list of authorized networks; this will make any public IP allowed to access the public endpoint
  # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks#access_to_control_plane_endpoints
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#master_authorized_networks_config
  master_authorized_networks = []

  # Provision only internal IP addresses for cluster nodes; no public IPs
  # Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept#architecture_of_private_clusters
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#enable_private_nodes
  enable_private_nodes = true

  # Allow the cluster to be updated to the latest Kubernetes version when upgraded
  # Reference: https://cloud.google.com/kubernetes-engine/versioning#specifying_cluster_version
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#min_master_version
  kubernetes_version = "latest"

  node_pools = [
    {
      name = "default-node-pool"

      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#machine_type
      machine_type = var.kubernetes_node_pool.machine_type

      # Rely on the cluster-wide node locations
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#node_locations
      # node_locations     = ...

      # Minimum number of nodes per zone in node pool
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#min_node_count
      min_count = var.kubernetes_node_pool.min_nodes

      # Maximum number of nodes per zone in node pool
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#max_node_count
      max_count = var.kubernetes_node_pool.max_nodes

      # No ephemeral SSDs for the nodes
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#local_ssd_count
      local_ssd_count = 0

      # Regular instances, not spot instances
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#spot
      spot = false

      # Size of primary disk, measured in GB
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#disk_size
      disk_size_gb = var.kubernetes_node_pool.disk_size_gb

      # Type of primary disk
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#disk_type
      disk_type = var.kubernetes_node_pool.disk_type

      # Use Container-Optimized OS with containerd
      # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-provisioning#default-image-type
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#image_type
      image_type = "COS_CONTAINERD"

      # Enable GCFS (Google Container File System), which in turn enables streaming of container images
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#gcfs_config
      enable_gcfs = true

      # Enable gVNIC (Google Virtual NIC), the successor to the VirtIO-based Ethernet driver
      # Reference: https://cloud.google.com/compute/docs/networking/using-gvnic
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#gvnic
      enable_gvnic = false

      # Enable auto-repair for nodes
      # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-repair
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#auto_repair
      auto_repair = true

      # Enable auto-upgrade for nodes
      # Once the control plane has been upgraded, these nodes will gradually be upgraded
      #   to match the control plane. This is done through rolling upgrades over several weeks.
      # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-upgrades
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#auto_upgrade
      auto_upgrade = true

      # Service account to use by VMs
      # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/service-accounts
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#service_account
      service_account = google_service_account.node_pool_service_account.email

      # Do not use preemptible VMs
      # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#preemptible
      preemptible = false

      # Default to min number of nodes
      # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#initial_node_count
      initial_node_count = var.kubernetes_node_pool.min_nodes
    },
  ]

  # Set OAuth scopes to typical settings
  # We do not use OAuth scopes to restrict access; instead, we use IAM roles on service accounts for that
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#oauth_scopes
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # We are not yet using node pool labels for anything useful
  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  # We are not yet using node pool metadata for anything useful
  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    # Only schedule pods that tolerate the 'default-node-pool' taint into the default node pool
    # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/node-taints
    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  # We are not yet using node pool tags for anything useful
  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
