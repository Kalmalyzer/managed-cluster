variable "region" {
    type = string
}

variable "billing_account" {
  type = string
}

variable "cluster_folder_id" {
  type = string
}

variable "cluster_project" {
  type = string
}

variable "app_folder" {
  type = string
}

variable "app_projects" {
  type = list(string)
}
