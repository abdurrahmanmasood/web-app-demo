# GKE Flask App Deployment with Terraform and GitHub Actionsp

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

- A Google Cloud Platform (GCP) project.
- Terraform installed on your local machine.
- Docker installed on your local machine.
- Helm installed on your local machine.
- A GitHub account.

## Setup Instructions

### 1. Create a Service Account for GitHub Actions

1. Navigate to the **Google Cloud Console**.
2. Go to **IAM & Admin** > **Service Accounts**.
3. Click on **Create Service Account**.
4. Fill in the required details (name, description) and click **Create**.
5. Assign the following permissions manually via the console:
   - Artifact Registry Administrator
   - Artifact Registry Writer
   - Compute Network Admin
   - Create Service Accounts
   - Kubernetes Engine Admin
   - Kubernetes Engine Cluster Admin
   - Service Account User
   - Service Usage Admin
   - Storage Object Admin
6. Click **Done** to finish creating the service account.
7. Generate a key for this service account and download the JSON key file.
8. Go to your GitHub repository and navigate to **Settings** > **Secrets and variables** > **Actions**.
9. Click on **New repository secret** and create a secret named `GOOGLE_APPLICATION_CREDENTIALS`, pasting the contents of the JSON key file.

### 2. Create a Storage Bucket

1. In the **Google Cloud Console**, navigate to **Cloud Storage**.
2. Click on **Create Bucket**.
3. Name your bucket (ensure it's unique across GCP).
4. Choose a location and set any other options as needed.
5. Click **Create** to finalize the bucket.

This bucket will be used to store the Terraform state file.

### 3. Configure Terraform

1. Clone the repository containing your Terraform code.
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```
2. Open the `variables.tfvars` file (or the equivalent Terraform configuration file).
3. Update the project ID and bucket name in the Terraform configuration.
   ```

## Running the Application

After successfully setting up the CI/CD pipeline, any changes pushed to your main branch will trigger the workflow, building the Docker image and deploying the application on your GKE cluster. 

You can access your Flask application using the external IP of your GKE service.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
