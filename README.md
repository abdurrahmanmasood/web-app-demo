# Python Flask App Deployment with Terraform and GitHub Actions on Google Kubernetes Engine

This project demonstrates how to create a Google Kubernetes Engine (GKE) cluster using Terraform, deploy a Flask application with Docker and Helm charts, and automate the CI/CD pipeline using GitHub Actions.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. Create a Service Account for GitHub Actions](#1-create-a-service-account-for-github-actions)
  - [2. Create a Storage Bucket](#2-create-a-storage-bucket)
  - [3. Configure Terraform](#3-configure-terraform)
  - [4. Set Up GitHub Actions CI/CD Pipeline](#4-set-up-github-actions-cicd-pipeline)
- [Running the Application](#running-the-application)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following:

- A Google Cloud project.
- Terraform installed on your local machine.
- Docker installed on your local machine.
- Helm installed on your local machine.
- Google Cloud CLI configured on your local machine.

## Setup Instructions

Open setup.sh file available in project root directory.

Set the following variables:

SERVICE_ACCOUNT_NAME="github-actions"
PROJECT_ID="wired-torus123"
BUCKET_NAME="terraform-state-file-$PROJECT_ID"
REGION="australia-southeast1 "

Run the bash file to perform the following tasks.

### 1. Creating Service Account for GitHub Actions

1. The bash file creates service account name as `github-actions`
2. The following permissions are assigned:
   - Artifact Registry Administrator
   - Artifact Registry Writer
   - Compute Network Admin
   - Create Service Accounts
   - Kubernetes Engine Admin
   - Kubernetes Engine Cluster Admin
   - Service Account User
   - Service Usage Admin
   - Storage Object Admin
   - Security Admin
3. After service account is created generate a key for this service account and download the JSON key file.
4. Go to your GitHub repository and navigate to **Settings** > **Secrets and variables** > **Actions**.
5. Click on **New repository secret** and create a secret named `GOOGLE_APPLICATION_CREDENTIALS`, pasting the contents of the JSON key file.

### 2. Creates a Storage Bucket for State file

1. The bash file creates a storage bucket name as `terraform-state-file-<project-id>`
2. After the bucket is created open providers.tfvars file in terraform directory.
3. Set this bucket name as backend for terraform.


This bucket will be used to store the Terraform state file.

### 3. Configure Terraform

1. Open the `variables.tfvars` file 
2. Set the variables name

- **Project ID**: `wired-torus123`
- **Region**: `australia-southeast1`
- **Zone**: `australia-southeast1-a`
- **Artifact Registry Repository**: `web-app-docker`
- **GKE Cluster**: `web-app-cluster`
- **GKE Service Account**: `gke-service-account`
- **GKE Cluster Node Pool**: `web-app-node-pool`
- **Network Name**: `vpc-network`

### 4. Configuring CI/CD pipeline

1. Open the `web-app-dev` , `web-app-stage`, `web-app-prod` file 
2. Set the `GCP_PROJECT` variable with your project name.

## Running the Infrastructure

After successfully setting up the CI/CD pipeline, any changes pushed to your production, staging, development branch will trigger the workflow, building the Docker image and deploying the application on your GKE cluster. 

You can access your Flask application using the external IP of your GKE service.

## Architecture Diagram

Here is the architecture diagram for the project:

![Architecture Diagram](web-app-demo.png)

## Security Considerations

### Least Privilege Access Control
We have implemented a **least privilege access control** model throughout the project. Instead of fine-grained control, this approach ensures that each service and user only has the permissions necessary to perform their tasks, thereby minimizing the risk of unauthorized access and potential security breaches.

#### 1.GitHub Actions Service Account
For deploying services through GitHub Actions, we utilize a dedicated service account. This account is configured with only the permissions required for deployment, ensuring that it does not have unnecessary access to other resources.

#### 2. GKE Service Account
In our GKE setup, we have created a **separate service account** rather than using the default one. This allows us to define specific permissions that the application needs to interact with cloud resources, further enforcing the principle of least privilege.

### Service Account Key Management
The service account key for GitHub Actions is securely stored as secrets in the GitHub repository. This protects sensitive credentials and prevents unauthorized access to our deployment processes.

### Namespace Isolation
We have created distinct **namespaces** in GKE for the **production**, **staging**, and **development** environments. This isolation allows us to manage resources separately and enhances security. By creating secrets specific to each environment within their own namespaces, we ensure that sensitive information is only accessible to the relevant environment, reducing the risk of cross-environment exposure.

### Firewall Rules
By default, when we create a firewall in our VPC, the following rules are established:

- **Inbound Rules**: 
  - Allow traffic from internal IPs within the VPC to all instances.
  - Allow traffic from public IPs to specific ports as defined by the user (e.g., HTTP, HTTPS).

- **Outbound Rules**:
  - Allow traffic to external IPs for all instances by default.

### HTTPS and SSL Certificates
To further secure our application, we can create SSL certificates for HTTPS connections. We can use **Google-managed SSL certificates**


With the SSL certificate in place, we can set up an **Ingress** resource with a custom domain, ensuring that all communications are encrypted.

### Ingress and Service Configuration

### Ingress: 
For accessing our application, with Ingress we can configure the service to use **NodePort** instead of a **LoadBalancer**. Here’s why this approach enhances security:

- **Ingress**: Ingress allows us to define routing rules for incoming traffic, providing a single entry point to the cluster. This minimizes the number of open ports on the nodes and allows for centralized management of SSL/TLS termination, simplifying certificate management.

### Service Types:

- **Load Balancer**: Using NodePort restricts exposure to the nodes’ public IP addresses. Unlike LoadBalancer services, which create external load balancers and expose a separate IP for each service, NodePort services only expose a specific port on each node's IP. This reduces the attack surface by limiting the number of publicly accessible IPs and ports.

- **Node Port**: Using NodePort restricts exposure to the nodes’ public IP addresses. Unlike LoadBalancer services, which create external load balancers and expose a separate IP for each service, NodePort services only expose a specific port on each node's IP. This reduces the attack surface by limiting the number of publicly accessible IPs and ports.

- **ClusterIP**: Using ClusterIP for internal services further secures our application by only allowing access from within the cluster. This prevents external traffic from directly accessing sensitive services, enhancing overall security.

