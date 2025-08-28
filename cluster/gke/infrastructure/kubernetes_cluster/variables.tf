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

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "ip_range_pods" {
  type = string
}

variable "ip_range_services" {
  type = string
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

variable "container_images_repository_id" {
  type = string
}
