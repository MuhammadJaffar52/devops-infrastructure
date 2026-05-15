DevOps Infrastructure Platform

Enterprise-grade AWS DevOps Infrastructure Platform built using:

Terraform.
AWS EKS
Kubernetes
Helm
Helmfile
Jenkins
Kaniko
Trivy
Trivy Operator
Prometheus
Grafana
Loki
External Secrets Operator
IRSA (IAM Roles for Service Accounts)
AWS Client VPN
Amazon ECR

This platform provides a fully automated, reusable, secure, 
and portable Kubernetes-based DevOps infrastructure
on AWS for deploying production-ready applications.

Project Goals

This platform was designed to achieve:

Infrastructure as Code (IaC)
Secure private Kubernetes infrastructure
CI/CD automation
Container image automation
Security scanning
Kubernetes security auditing
Monitoring & observability
Centralized logging
Multi-environment deployments
AWS account portability
Multi-region support
Production-grade Kubernetes architecture
Secure secret management
Reusable DevOps platform engineering
Platform Architecture
Infrastructure Layer (Terraform)

Terraform provisions:

VPC
Public Subnets
Private Subnets
Internet Gateway
NAT Gateway
Route Tables
Security Groups
EKS Cluster
Managed Node Groups
Dedicated Jenkins Node Group
IAM Roles
OIDC Provider
IRSA Roles
Amazon ECR Repositories
AWS Client VPN
CloudWatch integrations
Kubernetes Layer

Kubernetes workloads include:

Frontend application
Backend API
MongoDB StatefulSet
Jenkins CI/CD
Monitoring stack
Logging stack
Trivy Operator
External Secrets Operator
CI/CD Architecture

The Jenkins pipeline performs:

Source code checkout
Trivy filesystem security scanning
Docker image build using Kaniko
Push image to Amazon ECR
Kubernetes deployment update
Deployment rollout verification
Current Working Pipeline Features

The current Jenkins Kubernetes pipeline includes:

Dynamic Kubernetes Jenkins agents
Multi-container podTemplate
Trivy container
Kaniko container
kubectl container
Shared workspace volume
Dynamic image tagging using Jenkins BUILD_NUMBER
Automated Kubernetes rollout validation
Security Features
Trivy Filesystem Scanning

The pipeline scans:

npm dependencies
filesystem vulnerabilities
HIGH severity vulnerabilities
CRITICAL severity vulnerabilities
Trivy Operator

Continuously scans Kubernetes workloads for:

container vulnerabilities
RBAC misconfigurations
Kubernetes configuration issues
exposed secrets
security risks
IRSA (IAM Roles for Service Accounts)

IRSA is used to avoid static AWS credentials inside Kubernetes pods.

Benefits:

temporary credentials
least privilege access
improved security
IAM isolation per workload
External Secrets Operator

Secrets are securely stored inside:

AWS Secrets Manager

Secrets are automatically synchronized into Kubernetes.

No hardcoded secrets are stored inside GitHub.

Private VPN Architecture

This platform is designed as a:

PRIVATE DEVOPS PLATFORM

Access is restricted through AWS Client VPN.

Only authenticated VPN users can access:

Kubernetes API
Jenkins
Grafana
Prometheus
internal services
Monitoring & Observability
Prometheus

Collects metrics from:

Kubernetes
Nodes
Applications
Containers
Grafana

Provides dashboards for:

cluster monitoring
node monitoring
application monitoring
infrastructure observability
Loki

Provides centralized log aggregation for:

Kubernetes workloads
application logs
cluster logs
Project Structure
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
Technologies Used
Technology	Purpose
Terraform	Infrastructure provisioning
AWS EKS	Managed Kubernetes
Kubernetes	Container orchestration
Helm	Kubernetes package management
Helmfile	Multi-release deployment management
Jenkins	CI/CD automation
Kaniko	Container image builds
Trivy	Security scanning
Trivy Operator	Kubernetes runtime security
Prometheus	Metrics collection
Grafana	Visualization
Loki	Centralized logging
External Secrets	Secret synchronization
AWS Client VPN	Secure private access
Amazon ECR	Container registry
Infrastructure Design
VPC Design

The platform provisions:

Public Subnets
Private Subnets
NAT Gateway
Internet Gateway
Route Tables
Secure networking isolation
EKS Design

The EKS cluster includes:

Managed Node Groups
Dedicated Jenkins Node Group
OIDC Provider
IRSA Integration
Kubernetes autoscaling compatibility
AWS Load Balancer Controller compatibility
Environment Portability

The platform supports:

dev
staging
production

Each environment contains isolated Terraform configuration.

AWS Account Portability

The project supports dynamic AWS account detection using:

data "aws_caller_identity" "current" {}

Benefits:

no hardcoded account IDs
reusable infrastructure
multi-account support
easier migrations
AWS Region Portability

The project supports dynamic region configuration using:

provider "aws" {
  region = var.aws_region
}

Benefits:

multi-region deployments
reusable infrastructure
environment isolation
Current Jenkins Pipeline Workflow

The current working Jenkins pipeline includes:

Checkout Stage
checkout scm
Trivy Security Scan Stage

Scans source code before image build.

Example:

trivy fs \
  --severity HIGH,CRITICAL \
  --scanners vuln \
  --exit-code 0 \
  .
Build & Push Image Stage

Uses Kaniko to:

build Docker image
push image to ECR
tag image dynamically

Image tags:

frontend:${BUILD_NUMBER}
frontend:latest
Kubernetes Deployment Stage

Deploys updated image using:

kubectl set image deployment/frontend

Then validates rollout:

kubectl rollout status deployment/frontend
Successful Current Platform Validation

The platform currently validates successfully for:

Jenkins Kubernetes agents
Dynamic podTemplate execution
Trivy scanning
Kaniko image builds
Amazon ECR image push
Kubernetes rollout deployments
Frontend application deployment
Prerequisites

Before deployment ensure the following tools are installed.

Tool	Required
AWS CLI	Yes
kubectl	Yes
Terraform	Yes
Helm	Yes
Helmfile	Yes
Git	Yes
Docker	Optional
jq	Recommended
Recommended Versions
Tool	Version
Terraform	>= 1.5
kubectl	>= 1.30
Helm	>= 3.x
AWS CLI	>= 2.x
AWS Requirements

The AWS account must have permissions for:

EKS
EC2
IAM
ECR
CloudWatch
Secrets Manager
ACM
Route53 (optional)
Clone Repository
git clone https://github.com/MuhammadJaffar52/devops-infrastructure.git

cd devops-infrastructure
Configure AWS Credentials
aws configure

Provide:

AWS Access Key
AWS Secret Key
Default region
Output format
Verify AWS Access
aws sts get-caller-identity

Expected result:

{
  "Account": "XXXXXXXXXXXX",
  "Arn": "...",
  "UserId": "..."
}
Create Environment File
cp .env.example .env
Configure Environment Variables

Edit:

nano .env

Example:

AWS_REGION=eu-west-1
ENVIRONMENT=dev
Terraform Deployment
Navigate to Environment
cd terraform/environments/dev
Initialize Terraform
terraform init
Validate Terraform
terraform validate
Review Infrastructure Plan
terraform plan
Deploy Infrastructure
terraform apply -auto-approve
Configure kubectl Access

After EKS deployment:

aws eks update-kubeconfig \
  --region eu-west-1 \
  --name <cluster-name>
Validate Kubernetes Cluster
kubectl get nodes
Deploy Platform Components
helmfile apply
Automated Bootstrap Deployment

Entire platform deployment:

ENVIRONMENT=dev ./scripts/bootstrap.sh

This script performs:

Terraform initialization
Infrastructure provisioning
kubeconfig setup
Helm deployments
Kubernetes validation
Validate Platform
bash scripts/validate.sh
Jenkins Access
kubectl port-forward svc/jenkins -n jenkins 8080:8080

Access:

http://localhost:8080
Grafana Access
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

Access:

http://localhost:3000
Prometheus Access
kubectl port-forward svc/monitoring-kube-prometheus-prometheus \
-n monitoring 9090:9090

Access:

http://localhost:9090
Loki Validation
kubectl get pods -n monitoring
Trivy Operator Validation

Verify operator:

kubectl get pods -n trivy-system

Check vulnerability reports:

kubectl get vulnerabilityreports -A

Check configuration audit reports:

kubectl get configauditreports -A
Amazon ECR Validation

List repositories:

aws ecr describe-repositories

List images:

aws ecr list-images \
  --repository-name frontend
Deployment Workflow

Typical workflow:

Push code to GitHub
Jenkins pipeline triggers
Trivy scan executes
Kaniko builds image
Image pushed to Amazon ECR
Kubernetes deployment updated
Rollout validation executes
Monitoring stack tracks workloads
Trivy Operator continuously scans workloads
Reusing This Platform in Another AWS Account
Step 1 — Configure AWS Credentials
aws configure
Step 2 — Verify Account
aws sts get-caller-identity
Step 3 — Deploy Infrastructure
cd terraform/environments/dev

terraform init

terraform apply -auto-approve
Step 4 — Configure kubectl
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name <cluster-name>
Step 5 — Deploy Platform
helmfile apply
Step 6 — Configure Jenkins

Inside Jenkins:

create GitHub credentials
configure Kubernetes cloud
create pipeline jobs
Step 7 — Run Jenkins Pipeline.

The pipeline automatically:

scans code
builds images
pushes to ECR
deploys workloads
Destroy Infrastructure
./scripts/destroy.sh
Security Notes

This repository intentionally excludes:

AWS credentials
VPN private keys
secrets
sensitive environment variables

Secrets are securely managed using:

AWS Secrets Manager
External Secrets Operator
Current Production Readiness

Current platform capabilities:

Infrastructure automation
Private Kubernetes platform
CI/CD pipelines
Security scanning
Kubernetes runtime scanning
Monitoring
Centralized logging
VPN-only access
Environment portability
AWS account portability
Region portability
Reusable Jenkins pipelines
Planned Future Improvements

Planned enhancements:

Full parameterization
GitHub Actions support
ArgoCD GitOps
Multi-region failover
WAF integration
Automated backups
Service mesh
Production ingress
Terraform remote state locking
Advanced RBAC hardening
Dynamic Jenkins shared libraries
Cross-account deployments
Blue/Green deployments
Canary deployments
Repository

GitHub Repository - devops-infrastructure
