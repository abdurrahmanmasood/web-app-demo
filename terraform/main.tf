resource "google_project_service" "cloud_resource_manager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute_engine" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "kubernetes_engine" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = var.artifact_registry_repository
  format        = "DOCKER"
}

# resource "google_compute_global_address" "static_ip_global" {
#   name = "web-app-dev"
# }

# Create a VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = true
  depends_on              = [google_project_service.compute_engine]
}

# # Create Firewall Rule to Allow Internal Traffic
# resource "google_compute_firewall" "allow_internal" {
#   name    = "allow-internal"
#   network = google_compute_network.vpc_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["8080"] # Allow all TCP traffic
#   }

#   source_ranges = ["10.0.0.0/24"] # Adjust based on your subnetwork CIDR
#   target_tags   = ["flask-app"]

# }

# # Create Firewall Rule to Allow External Traffic to GKE API
# resource "google_compute_firewall" "allow_gke_api" {
#   name    = "allow-gke-api"
#   network = google_compute_network.vpc_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["443"] # Allow HTTPS traffic for GKE API
#   }

#   source_ranges = ["0.0.0.0/0"] # Allow access from anywhere (consider restricting this)
#   target_tags   = ["flask-app"]

# }

resource "google_service_account" "default" {
  account_id   = "gke"
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc_network.name
  deletion_protection      = false
  depends_on               = [google_project_service.kubernetes_engine]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.gke_cluster_node_pool
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}