resource "google_project_service" "cloud_resource_manager" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "compute_engine" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = true
  depends_on         = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "iam_api" {
  project            = var.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "kubernetes_engine" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = true
}

# resource "google_compute_network" "vpc_network" {
#   project                 = var.project_id
#   name                    = var.vpc_network
#   auto_create_subnetworks = true
#   depends_on              = [google_project_service.compute_engine]
# }

resource "google_compute_address" "static_ip" {
  name         = "my-static-ip"
  region       = var.region
  address_type = "EXTERNAL"
  description  = "Web App Static IP"
}

output "static_ip_address" {
  value = google_compute_address.static_ip.address
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = var.artifact_registry_repository
  format        = "DOCKER"
}


resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
  depends_on   = [google_project_service.iam_api]
}

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on               = [google_project_service.kubernetes_engine]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [google_project_service.iam_api]
}