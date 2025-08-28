project_id = "kalmalyzer-managed-cluster"

# Location which the managed cluster will operate in. Choose a location that is near to you.
# Reference: https://cloud.google.com/about/locations
region     = "europe-west1"

zones = [
  # Zones within the region, where the GKE cluster will operate.
  #
  # There will be one control plane node in each zone. This means that if you add more zones
  #   you get redundancy/HA for the control plane.
  #
  # In addition, whenever a node pool scales up/down, it will create one node in each zone.
  # This means that if you want to run a small cluster (which scales up with just 1 node at a time),
  #   you don't want to spread the cluster over multiple zones. You don't get redundancy/HA for the
  #   worker nodes, but that is usually not so important for internal IT operations; many of
  #   the applications don't support redundancy/HA anyway.
  
  "europe-west1-b",
]

cluster_name = "managed-cluster"

kubernetes_cluster_network_config = {
  vms_cidr_range      = "10.117.2.0/24"
  pods_cidr_range     = "10.117.16.0/20"
  services_cidr_range = "10.117.3.0/24"
}

kubernetes_node_pool = {
  min_nodes    = 0
  max_nodes    = 10
  machine_type = "n2-standard-2"
  disk_type    = "pd-balanced"
  disk_size_gb = 100
}

ssl_certificates = [
  # Google-managed SSL certificates
  # These can be referenced from Gateway manifests to perform HTTPS => HTTP termination at the load balancer
  # Be aware that adding a new Google-managed SSL certificate requires manual DNS actions on your behalf,
  #   and provisioning is not instant.
  # Reference: https://cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs#terraform
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate
  # Reference: https://cloud.google.com/kubernetes-engine/docs/how-to/secure-gateway#secure-using-ssl-certificate

  # SSL cert resources cannot be modified once created. Furthermore, they cannot be deleted while they are still in use by
  #   other infrastructure (such as load balancers). Because of this, we will typically not modify existing SSL certs,
  #   but instead we introduce new certs whenever we want to modify the domains of a certificate. Once the new SSL cert
  #   has been created, we then need to modify the dependent resource (GKE gateway / load balancer) to use the new cert.
  #
  # When introducing a new cert, copy/paste the latest one here, modify the list of domains in the copy, and give the copy a
  #   new ID. The gateway/load balancer will need to be updated to reference the new ID.

  {
    domains = [
      "argocd.kalms.org",
    ]
    id = "argocd-kalms-org-1"
  },

  // Older certs. These can be removed from here, once no other infrastructure uses them any more

  {
    domains = [
      "test.kalms.org",
    ]
    id = "test-kalms-org-1"
  },

  # {
  #   domains = [
  #     "test2.kalms.org",
  #   ]
  #   id = "test2-kalms.org-1"
  # },
]

static_global_ip_addresses = [

  # Pre-allocated global IP addresses
  # These decouple the life cycle of IPv4 addresses from the life cycle of load balancers
  #   and thus, DNS entries can be configured once, and they will remain valid even as load balancers are created/destroyed

  # This address is used by the Global HTTP(S) Load Balancer associated with our main Gateway
  {
    id = "apps-external-ip",
  },

]

static_regional_ip_addresses = [

  # Pre-allocated regional IP addresses
  # These decouple the life cycle of IPv4 addresses from the life cycle of load balancers
  #   and thus, DNS entries can be configured once, and they will remain valid even as load balancers are created/destroyed

  # This address is used by the TCP Passthrough Load Balancer associated with our Nginx Ingress controller
  {
    id     = "ingress-nginx-ip",
    region = "europe-west1",
  },

]

iap_accessors = [
  # Allow users in this pre-defined group to access any resources that are protected behind an Identity-Aware Proxy
  # "group:managed-cluster-iap@kalms.org",
]
