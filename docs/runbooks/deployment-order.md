# Deployment Order

## 1. Clone Repository

git clone https://github.com/MuhammadJaffar52/devops-infrastructure.git

## 2. Configure AWS CLI

aws configure

## 3. Export Environment Variables

cp .env.example .env

## 4. Deploy Terraform

cd terraform/environments/dev

terraform init
terraform apply

## 5. Configure kubectl

aws eks update-kubeconfig --region eu-west-1 --name devops-eks

## 6. Deploy Platform

helmfile apply

## 7. Deploy Applications

kubectl apply -f k8s/apps/
