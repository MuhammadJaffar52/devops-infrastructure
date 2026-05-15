# DevOps Infrastructure Platform

Enterprise-grade AWS DevOps Infrastructure Platform built using:

* Terraform
* AWS EKS
* Kubernetes
* Helm
* Jenkins
* Kaniko
* Trivy Operator
* Prometheus
* Grafana
* Loki
* AWS Client VPN
* External Secrets
* IRSA (IAM Roles for Service Accounts)

This project provides a fully automated, reusable, 
and portable DevOps infrastructure platform
designed for secure Kubernetes-based 
application deployment on AWS.

---

# Project Goals

This platform provides:

* Infrastructure as Code (IaC)
* Secure private Kubernetes infrastructure
* CI/CD automation
* Security scanning
* Monitoring & observability
* Environment portability
* Multi-account AWS support
* Multi-region deployment support
* Production-grade architecture

---

# Architecture Overview

The platform consists of:

## Infrastructure Layer (Terraform)

Terraform provisions:

* VPC
* Public & private subnets
* NAT Gateway
* Route tables
* EKS cluster
* Node groups
* IAM roles
* OIDC provider
* IRSA roles
* AWS Client VPN
* ECR repositories

---

## Kubernetes Layer

Kubernetes workloads include:

* Frontend application
* Backend API
* MongoDB StatefulSet
* Jenkins
* Monitoring stack
* External Secrets
* Trivy Operator

---

## Monitoring Stack

Monitoring includes:

* Prometheus
* Grafana
* Loki
* Promtail
* Node Exporter

---

## Security Stack

Security components include:

* Trivy Operator
* Trivy filesystem scanning
* IRSA
* AWS Secrets Manager
* External Secrets Operator
* Private VPN-only cluster access

---

# Project Structure

```text
devops-infrastructure/

├── apps/
│   ├── backend/
│   └── frontend/
│
├── docs/
│   └── runbooks/
│
├── helm/
│   ├── helmfile.yaml
│   ├── releases/
│   └── values/
│
├── jenkins/
│   └── pipelines/
│       └── frontend.Jenkinsfile
│
├── k8s/
│   ├── apps/
│   ├── base/
│   ├── monitoring/
│   └── platform/
│
├── scripts/
│   ├── bootstrap.sh
│   ├── deploy.sh
│   ├── destroy.sh
│   └── validate.sh
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   │
│   ├── global/
│   ├── modules/
│   └── policies/
│
└── .env.example
```

---

# Technologies Used

| Technology       | Purpose                        |
| ---------------- | ------------------------------ |
| Terraform        | Infrastructure provisioning    |
| AWS EKS          | Kubernetes cluster             |
| Kubernetes       | Container orchestration        |
| Helm             | Kubernetes package management  |
| Helmfile         | Multi-release Helm deployments |
| Jenkins          | CI/CD automation               |
| Kaniko           | Container image builds         |
| Trivy            | Security scanning              |
| Prometheus       | Metrics collection             |
| Grafana          | Visualization                  |
| Loki             | Centralized logging            |
| External Secrets | Secret synchronization         |
| AWS Client VPN   | Secure private access          |
| ECR              | Container registry             |

---

# Infrastructure Design

## VPC

The platform deploys a custom VPC including:

* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables

---

## EKS Cluster

The EKS cluster includes:

* Managed node groups
* Separate Jenkins node group
* OIDC provider
* IRSA integration
* AWS Load Balancer Controller support

---

## VPN Architecture

The entire platform is designed as a:

PRIVATE DEVOPS PLATFORM

Applications and dashboards are accessible only through AWS Client VPN.

This ensures:

* private cluster access
* secure admin access
* internal-only services
* restricted exposure

---

# CI/CD Pipeline

The Jenkins pipeline performs:

1. Source code checkout
2. Trivy filesystem scan
3. Docker image build using Kaniko
4. Push image to ECR
5. Deploy updated image to Kubernetes

---

# Security Features

## Trivy Operator

Automatically scans:

* workloads
* containers
* RBAC
* Kubernetes configurations

---

## External Secrets

Secrets are stored in:

AWS Secrets Manager

And synchronized automatically into Kubernetes.

---

## IRSA

IAM Roles for Service Accounts are used to avoid static AWS credentials inside pods.

---

# Monitoring Features

## Prometheus

Collects metrics from:

* Kubernetes
* Nodes
* Applications

---

## Grafana

Provides dashboards for:

* cluster metrics
* node metrics
* application monitoring

---

## Loki

Provides centralized log aggregation.

---

# Environment Portability

This project supports:

dev
staging
production

Each environment contains isolated Terraform configuration.

---

# AWS Account Portability

The platform supports dynamic AWS account detection using:

data "aws_caller_identity" "current" {}
```

This removes hardcoded account dependency.

---

# Region Portability

The project supports dynamic region configuration using:

provider "aws" {
  region = var.aws_region
}
```

---

# Prerequisites

Before deployment ensure the following tools are installed:

| Tool      | Required |
| --------- | -------- |
| AWS CLI   | Yes      |
| kubectl   | Yes      |
| Terraform | Yes      |
| Helm      | Yes      |
| Helmfile  | Yes      |
| Git       | Yes      |

---

# AWS Requirements

The AWS account must have permissions for:

* EKS
* EC2
* IAM
* ECR
* ACM
* Route53 (optional)
* CloudWatch
* Secrets Manager

---

# Initial Setup

## Step 1 — Clone Repository

```bash
git clone https://github.com/MuhammadJaffar52/devops-infrastructure.git

cd devops-infrastructure
```

---

## Step 2 — Configure AWS Credentials

```bash
aws configure

Provide:

* AWS Access Key
* AWS Secret Key
* Default region
* Output format

---

## Step 3 — Verify AWS Access

```bash
aws sts get-caller-identity
```

---

## Step 4 — Create Environment File

Copy:

```bash
cp .env.example .env
```

---

## Step 5 — Configure Variables

Edit the environment file:

nano .env

Example:

AWS_REGION=eu-west-1
ENVIRONMENT=dev
```

---

# Terraform Deployment

## Initialize Terraform

```bash
cd terraform/environments/dev
Initialize Terraform
terraform init
Validate Terraform
terraform validate
Review Infrastructure Plan
terraform plan
Deploy Infrastructure
terraform apply -auto-approve
```

---

# Automated Bootstrap Deployment

The entire platform can be deployed automatically using:

ENVIRONMENT=dev ./scripts/bootstrap.sh

This script performs:

* Terraform initialization
* Infrastructure provisioning
* kubeconfig setup
* Helm deployments

---

# Kubernetes Validation

Validate cluster resources:

```bash
bash scripts/validate.sh
```

---

# Jenkins Access

Port forward Jenkins:

```bash
kubectl port-forward svc/jenkins -n jenkins 8080:8080

Access:

http://localhost:8080
```

---

# Grafana Access

Port forward Grafana:

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

Access:

http://localhost:3000
```

---

# Prometheus Access

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus \
-n monitoring 9090:9090

Access:

http://localhost:9090
```

---

# Trivy Operator Validation

Verify operator:

kubectl get pods -n trivy-system

Check vulnerability reports:

kubectl get vulnerabilityreports -A

Check configuration audit reports:

kubectl get configauditreports -A
```

---

# Deployment Workflow

Typical workflow:

1. Push code to GitHub
2. Jenkins pipeline triggers
3. Trivy scan executes
4. Kaniko builds image
5. Image pushed to ECR
6. Kubernetes deployment updated
7. Monitoring tracks workloads
8. Trivy Operator scans workloads continuously

---

# Destroy Infrastructure

To destroy infrastructure:

```bash
./scripts/destroy.sh
```

---

# Future Improvements

Planned enhancements:

* GitHub Actions support
* ArgoCD GitOps
* Multi-region failover
* WAF integration
* Automated backups
* Service mesh
* Production ingress
* Terraform remote state locking
* Advanced RBAC hardening

---

# Security Notes

This repository intentionally excludes:

AWS credentials
VPN private keys
secrets
sensitive environment variables

Secrets are securely managed using:

* AWS Secrets Manager
* External Secrets Operator

---

# Production Readiness

Current platform capabilities:

* Infrastructure automation
* Private Kubernetes platform
* CI/CD pipelines
* Security scanning
* Monitoring
* Logging
* VPN-only access
* Environment portability
* AWS account portability


