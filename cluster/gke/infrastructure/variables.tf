variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
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

variable "kubernetes_node_pool" {
  type = object({
    min_nodes    = number
    max_nodes    = number
    machine_type = string
    disk_type    = string
    disk_size_gb = number
  })
}

variable "ssl_certificates" {
  type = list(object({
    domains = list(string)
    id      = string
  }))
}

variable "static_global_ip_addresses" {
  type = list(object({
    id = string
  }))
}

variable "static_regional_ip_addresses" {
  type = list(object({
    id     = string
    region = string
  }))
}

variable "iap_accessors" {
  type = list(string)
}
