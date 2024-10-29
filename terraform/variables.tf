variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
}

variable "vpc_network" {
  description = "VPC network name"
  type        = string
}

variable "gke_cluster" {
  description = "GKE Cluster name"
  type        = string
}

variable "gke_cluster_node_pool" {
  description = "GKE Cluster node pool name"
  type        = string
}