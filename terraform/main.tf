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

resource "google_compute_global_address" "static_ip_global" {
  name = "flask-app-static-ip"
}

# Create a VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute_engine]
}

# Create a Cloud Router for the NAT gateway
resource "google_compute_router" "my_router" {
  name    = "my-router123"
  region  = var.region
  network = google_compute_network.vpc_network.name
}

# Create a NAT gateway
resource "google_compute_router_nat" "my_nat_gateway" {
  name   = "my-nat-gateway"
  region = var.region
  router = google_compute_router.my_router.name

  nat_ip_allocate_option             = "AUTO_ONLY" # Use auto-allocated external IPs
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Create Subnets
resource "google_compute_subnetwork" "subnetwork" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.0.0.0/24" # Adjust the CIDR range as needed
  region        = var.region    # Must match the region in the provider block
  network       = google_compute_network.vpc_network.name
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

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster
  location                 = "australia-southeast1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc_network.name
  subnetwork               = google_compute_subnetwork.subnetwork.name

  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.0.1.0/28" # Reserved for GKE master endpoint
    enable_private_endpoint = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = ""     # Replace with your public IP
      display_name = "Home" # A name for easier identification
    }
  }
  deletion_protection = false
  depends_on          = [google_project_service.kubernetes_engine]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.gke_cluster_node_pool
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}