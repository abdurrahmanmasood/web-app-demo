variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
}

variable "zone" {
  description = "Region for resources"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork."
  type        = string
}

variable "artifact_registry_repository" {
  description = "Docker repository name"
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