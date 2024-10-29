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

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = var.artifact_registry_repository
  format        = "DOCKER"
}

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on               = [google_project_service.kubernetes_engine]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.gke_cluster_node_pool
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
}