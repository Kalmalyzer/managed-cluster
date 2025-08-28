variable "project_id" {
  type = string
}

variable "region" {
  type    = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_cluster_network_config" {
  type = object({
    vms_cidr_range      = string
    pods_cidr_range     = string
    services_cidr_range = string
  })
}
