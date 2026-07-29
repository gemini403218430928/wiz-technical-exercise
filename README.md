# DevSecOps & Cloud Security Technical Exercise

A demonstration of cloud-native infrastructure deployment on **Google Cloud Platform (GCP)**, incorporating automated DevSecOps CI/CD pipelines, containerized application delivery on **Google Kubernetes Engine (GKE)**, and security architecture features including intentional security scenarios for vulnerability detection, audit logging, and preventative WAF controls.

---

## 🏛️ Architecture Overview

The repository provisions a 2-tier application architecture on GCP alongside security tooling and automated CI/CD security scanning workflows.

```
                  +-------------------------------------------------------------+
                  |                         Google Cloud                        |
                  |                                                             |
+--------------+  |  +--------------------+    +-----------------------------+  |
|  Internet /  |  |  |  Google Cloud      |    | Private GKE Cluster         |  |
| External User|---> |  Armor WAF         |--->| (wiz-gke-cluster)           |  |
+--------------+  |  | (block-bad-actors) |    |  - wiz-web-app (3 Replicas) |  |
                  |  +--------------------+    |  - ServiceAccount:          |  |
                  |                            |    cluster-admin bound      |  |
                  |                            +--------------+--------------+  |
                  |                                           |                 |
                  |                                     MongoDB Access          |
                  |                                      (Port 27017)           |
                  |                                           v                 |
                  |                            +-----------------------------+  |
                  |                            | Compute Engine VM           |  |
                  |                            | (wiz-mongo-vm)              |  |
                  |                            |  - MongoDB 4.4 (Ubuntu 22.04)|  |
                  |                            |  - Daily Backup Script      |  |
                  |                            +--------------+--------------+  |
                  |                                           |                 |
                  |                                     Backup Upload           |
                  |                                           v                 |
                  |                            +-----------------------------+  |
                  |                            | Public GCS Backup Bucket    |  |
                  |                            | (wiz-db-backups-*)          |  |
                  |                            +-----------------------------+  |
                  +-------------------------------------------------------------+
```

---

## 📦 Components & Repository Structure

```
.
├── app/                        # 2-Tier Flask ToDo Application
│   ├── app.py                  # Flask backend API & MongoDB connection logic
│   ├── Dockerfile              # Container image build file
│   ├── requirements.txt        # Python dependencies (Flask, PyMongo)
│   └── templates/
│       └── index.html          # Frontend ToDo UI (Bootstrap 5)
├── k8s-app.yaml                # Kubernetes Deployment, Service, Ingress & BackendConfig
├── terraform/                  # Infrastructure as Code (GCP)
│   ├── audit_logs.tf           # GCP Data Access Audit Logging (Storage & Compute)
│   ├── cloud_armor.tf          # Cloud Armor WAF policy (Log4j CVE-2021-44228 mitigation)
│   ├── firewall.tf             # VPC Firewall Rules
│   ├── gcs.tf                  # Database Backup Bucket configuration
│   ├── gke.tf                  # Private GKE Cluster & Node Pool provisioning
│   ├── iam.tf                  # Service Accounts and IAM RBAC permissions
│   ├── outputs.tf              # Terraform outputs (IPs, Bucket URLs, Cluster Name)
│   ├── providers.tf            # Terraform GCP provider & GCS remote backend config
│   ├── scc.tf                  # GCP Security Command Center API configuration
│   ├── terraform.tfvars        # Project variables (Project ID, Region, Zone)
│   ├── variables.tf            # Input variable declarations
│   ├── vm.tf                   # MongoDB Compute Instance & Startup Scripts
│   └── vpc.tf                  # Custom VPC, Subnets, Cloud Router & NAT Gateway
└── .github/workflows/          # Automated GitHub Actions Pipelines
    ├── app-cicd.yml            # App Container CI/CD & Security Scanning Pipeline
    └── iac-cicd.yml            # IaC Security Scanning (Checkov) & Infrastructure Pipeline
```

---

## 🔒 Security Architecture & Intentional Scenarios

This repository includes intentional security scenarios and misconfigurations designed to test and validate DevSecOps security scanning tools, posture management, and threat detection engines:

1. **Overly Permissive Firewall Rules**:
   - VM firewall (`allow-public-ssh`) opens SSH (port 22) to `0.0.0.0/0`.
2. **Publicly Readable Storage Bucket**:
   - GCS Backup bucket (`wiz-db-backups-*`) assigns `roles/storage.objectViewer` to `allUsers`.
3. **Excessive IAM Privileges**:
   - Compute Engine Service Account (`wiz-vm-sa`) is granted full `roles/compute.admin` and `roles/storage.admin`.
   - GKE Service Account (`wiz-app-sa`) is bound to `cluster-admin` via ClusterRoleBinding.
4. **Outdated OS & Software**:
   - VM provisions an outdated Ubuntu image with MongoDB 4.4.
5. **Preventative & Detective Controls**:
   - **Google Cloud Armor WAF**: Rules attached via GKE Ingress `BackendConfig` to mitigate CVE-2021-44228 (Log4j) and demonstrate IP blocking capabilities.
   - **Audit Logging**: Data Access Audit Logging enabled for GCP Compute Engine and Storage services.
   - **Security Command Center**: Security Command Center API enabled for continuous threat detection.

---

## 🚀 CI/CD & DevSecOps Pipelines

The project features automated GitHub Actions workflows leveraging **Workload Identity Federation** for keyless GCP authentication:

### 1. IaC DevSecOps Pipeline (`.github/workflows/iac-cicd.yml`)
- **Trigger**: Changes to `terraform/**` on `main` or pull requests.
- **Security Scan**: Runs **Checkov IaC Scanner** to detect security risks and compliance issues in Terraform manifests, uploading SARIF output to the GitHub Security tab.
- **Deployment**: Automatically executes `terraform init` and `terraform apply -auto-approve` upon push to `main`.

### 2. Application Container CI/CD Pipeline (`.github/workflows/app-cicd.yml`)
- **Trigger**: Changes to `app/**` or `k8s-app.yaml` on `main` or pull requests.
- **Dependency Vulnerability Scan**: Uses **Trivy FS Scanner** to scan `requirements.txt` and publishes SARIF alerts to GitHub Security.
- **Container Image Scan**: Uses **Trivy Container Scanner** to analyze OS packages and image layers, rendering a detailed markdown vulnerability report in the GitHub Job Summary.
- **Build & Deployment**: Builds Docker image, pushes to GCP **Artifact Registry**, updates GKE deployment, and verifies rollout status.

---

## 🛠️ Getting Started & Deployment

### Prerequisites
- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.3.0`
- [Docker](https://docs.docker.com/get-docker/) & `kubectl`

### Local Development & Setup

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd wiz-technical-exercise
   ```

2. **Configure GCP Variables**:
   Update `terraform/terraform.tfvars` with your GCP project details:
   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   zone       = "us-central1-a"
   ```

3. **Deploy Infrastructure via Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. **Deploy Application to GKE**:
   ```bash
   # Connect to GKE Cluster
   gcloud container clusters get-credentials wiz-gke-cluster --region us-central1 --project <your-gcp-project-id>

   # Apply Kubernetes Manifests
   kubectl apply -f k8s-app.yaml
   ```

5. **Verify Web Application & Endpoint**:
   Check application health status via the HTTP endpoint:
   ```bash
   curl http://<INGRESS_OR_SERVICE_IP>/healthz
   ```
