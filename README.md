# 🚀 Enterprise DevOps Platform on AWS EKS

## Overview

This project demonstrates the design, automation, deployment, monitoring, security, and management of a production-style Kubernetes platform on AWS.

The platform is built using Infrastructure as Code (IaC) principles and follows modern DevOps practices including:

* Terraform-based infrastructure provisioning
* Private Amazon EKS cluster deployment
* Jenkins CI/CD automation
* Kubernetes application deployment
* Centralized logging
* Monitoring and observability
* Security scanning
* Secrets management
* VPN-only administrative access

The objective is to simulate a real-world enterprise DevOps environment where infrastructure, applications, monitoring, and security are managed through automation.

---

# Architecture Overview

## Infrastructure Layer

Provisioned using Terraform.

### AWS Resources

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* IAM Roles & Policies
* IAM OIDC Provider
* Amazon EKS Cluster
* Managed Node Groups
* AWS Client VPN
* Amazon ECR Repositories

---

## Kubernetes Layer

### Application Namespace

Deployed application stack:

#### Frontend

* Kubernetes Deployment
* Kubernetes Service
* ALB Ingress

#### Backend API

* Kubernetes Deployment
* Kubernetes Service

#### MongoDB

* StatefulSet
* Persistent Storage
* Internal Cluster Service

---

## CI/CD Platform

### Jenkins

Dedicated Jenkins deployment running inside Kubernetes.

Capabilities:

* Source Code Checkout
* Pull Request Validation
* Automated Build
* Docker Image Creation
* Image Push to ECR
* Kubernetes Deployment Automation

### Jenkins Agents

Separate node group created specifically for CI/CD workloads.

Benefits:

* Isolated build workloads
* Better scalability
* Reduced impact on application nodes

---

# Monitoring & Observability

## Grafana

Provides dashboards for:

* Cluster monitoring
* Application monitoring
* Infrastructure visibility

Deployment:

* Kubernetes Deployment
* ClusterIP Service
* Access through VPN + Port Forwarding

---

## Loki

Centralized log aggregation platform.

Collects:

* Kubernetes Pod Logs
* Application Logs
* System Logs

---

## Promtail

Runs as DaemonSet.

Responsibilities:

* Collect node logs
* Collect container logs
* Forward logs to Loki

---

# Code Quality Platform

## SonarQube

Deployed inside Kubernetes using Helm.

Capabilities:

* Static Code Analysis
* Code Smell Detection
* Bug Detection
* Security Vulnerability Analysis
* Technical Debt Reporting
* Quality Gates

Current Deployment:

* SonarQube Community Edition
* Kubernetes StatefulSet
* ClusterIP Service
* Internal Access Only

---

# Security Architecture

## External Secrets Operator

Secrets are stored securely in:

* AWS Secrets Manager

Automatically synchronized into Kubernetes secrets.

---

## IRSA

IAM Roles for Service Accounts

Benefits:

* No static AWS credentials
* Least privilege access
* Secure AWS authentication from pods

---

## Trivy Security Scanning

Security scanning architecture prepared for:

* Container Images
* Kubernetes Resources
* Configuration Auditing
* Vulnerability Reporting

---

# VPN Architecture

## AWS Client VPN

Administrative access to infrastructure is provided through AWS Client VPN.

### Accessible Through VPN

* Jenkins
* Grafana
* SonarQube
* Internal Kubernetes Services
* EKS API Access

### Benefits

* No public dashboards
* Secure administrative access
* Private cluster management
* Reduced attack surface

---

# Current Kubernetes Resources

## Namespaces

* app
* monitoring
* jenkins
* sonarqube
* external-secrets
* kube-system

---

## Application Components

### Frontend

* 2 Replicas
* Kubernetes Deployment
* ALB Ingress

### Backend

* 2 Replicas
* Kubernetes Deployment

### MongoDB

* StatefulSet

---

## Monitoring Components

### Grafana

Visualization Platform

### Loki

Centralized Logging

### Promtail

Log Collection

---

## DevOps Components

### Jenkins

CI/CD Server

### Jenkins Agent

Build Executors

---

## Quality Components

### SonarQube

Code Quality & Security Analysis

---

# Repository Structure

```text
devops-infrastructure/

├── apps/
│   ├── frontend/
│   └── backend/
│
├── docs/
│   └── runbooks/
│
├── helm/
│   ├── releases/
│   └── values/
│
├── jenkins/
│   └── pipelines/
│
├── k8s/
│   ├── apps/
│   ├── monitoring/
│   ├── platform/
│   └── base/
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
│   ├── modules/
│   ├── global/
│   └── policies/
│
└── .env.example
```

---

# Deployment Workflow

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins Pipeline
    │
    ├── Source Checkout
    ├── SonarQube Analysis
    ├── Security Scan
    ├── Build Image
    ├── Push Image to ECR
    │
    ▼
Kubernetes Deployment
    │
    ▼
Amazon EKS
```

---

# Monitoring Flow

```text
Applications
      │
      ▼
 Promtail
      │
      ▼
   Loki
      │
      ▼
 Grafana
```

---

# Security Features

* Private EKS Cluster
* AWS Client VPN Access
* IRSA Authentication
* Secrets Manager Integration
* External Secrets Operator
* SonarQube Code Analysis
* Trivy Security Scanning
* Least Privilege IAM Design

---

# Environment Support

Supported environments:

* Development
* Staging
* Production

Each environment uses isolated Terraform configurations.

---

# AWS Services Used

* Amazon EKS
* Amazon EC2
* Amazon VPC
* Amazon IAM
* Amazon ECR
* AWS Client VPN
* AWS ACM
* AWS Secrets Manager
* CloudWatch
* Elastic Load Balancer

---

# Current Platform Status

### Infrastructure

✅ VPC Provisioned

✅ EKS Cluster Running

✅ Managed Node Groups Running

✅ AWS Client VPN Operational

### Applications

✅ Frontend Running

✅ Backend Running

✅ MongoDB Running

### DevOps

✅ Jenkins Running

✅ CI/CD Pipelines Configured

### Monitoring

✅ Grafana Running

✅ Loki Running

✅ Promtail Running

### Quality

✅ SonarQube Running

### Security

✅ External Secrets Running

✅ IRSA Configured

---

# Future Enhancements

* ArgoCD GitOps
* Prometheus Stack
* Metrics Server
* Cluster Autoscaler
* Velero Backup & Recovery
* Multi-Region DR
* WAF Integration
* Advanced RBAC
* Service Mesh (Istio)
* GitHub Actions Support

---

# Author

Muhammad Jaffar

DevOps Engineer

AWS • Kubernetes • Terraform • Jenkins • Observability • Security
