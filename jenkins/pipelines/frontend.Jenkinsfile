pipeline {
  agent {
    kubernetes {
      inheritFrom 'jenkins'

      yaml """
apiVersion: v1
kind: Pod
metadata:
  namespace: jenkins

spec:
  serviceAccountName: jenkins

  containers:

  - name: trivy
    image: aquasec/trivy:latest
    command:
      - cat
    tty: true

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
      - cat
    tty: true
    env:
      - name: AWS_REGION
        value: eu-west-1

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
      - cat
    tty: true
"""
    }
  }

  environment {
    AWS_REGION = "eu-west-1"
    AWS_ACCOUNT_ID = "744804011934"

    ECR_REPO = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
    IMAGE_TAG = "${BUILD_NUMBER}"

    NAMESPACE = "app"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Trivy Security Scan') {
      steps {
        container('trivy') {
          sh '''
            echo "=============================="
            echo "Running Trivy Scan"
            echo "=============================="

            trivy fs \
              --severity HIGH,CRITICAL \
              --scanners vuln \
              --exit-code 0 \
              .

            echo "Scan completed"
          '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        container('kaniko') {

          sh '''
            set -e

            echo "=============================="
            echo "Creating Docker Config"
            echo "=============================="

            mkdir -p /kaniko/.docker

            TOKEN=$(wget -qO- \
              --header="X-aws-ec2-metadata-token-ttl-seconds: 21600" \
              --method PUT \
              "http://169.254.169.254/latest/api/token" || true)

            echo "Using IRSA / IAM permissions"

            cat > /kaniko/.docker/config.json <<EOF
{
  "credHelpers": {
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": "ecr-login"
  }
}
EOF

            echo "=============================="
            echo "Building & Pushing Image"
            echo "=============================="

            /kaniko/executor \
              --context=/home/jenkins/agent/workspace/frontend-pipeline/apps/frontend \
              --dockerfile=/home/jenkins/agent/workspace/frontend-pipeline/apps/frontend/Dockerfile \
              --destination=${ECR_REPO}:${IMAGE_TAG} \
              --destination=${ECR_REPO}:latest \
              --cache=true \
              --verbosity=info
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {

        container('kubectl') {

          sh '''
            echo "=============================="
            echo "Deploying Frontend"
            echo "=============================="

            kubectl set image deployment/frontend \
              frontend=${ECR_REPO}:${IMAGE_TAG} \
              -n ${NAMESPACE}

            kubectl rollout status deployment/frontend \
              -n ${NAMESPACE}
          '''
        }
      }
    }
  }

  post {

    success {
      echo "✅ Frontend Pipeline Completed Successfully"
    }

    failure {
      echo "❌ Frontend Pipeline Failed"
    }
  }
}