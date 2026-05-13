pipeline {
  agent {
    kubernetes {
      label 'frontend-agent'
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
    command: ["cat"]
    tty: true

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["cat"]
    tty: true
    env:
    - name: AWS_REGION
      value: eu-west-1

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true

  volumes:
  - name: workspace-volume
    emptyDir: {}
"""
    }
  }

  environment {
    AWS_REGION = "eu-west-1"
    ECR_REPO   = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
    IMAGE_TAG  = "latest"
    NAMESPACE  = "app"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Trivy Scan') {
      steps {
        container('trivy') {
          sh """
            echo "=============================="
            echo "Running Trivy Scan"
            echo "=============================="

            trivy fs --severity HIGH,CRITICAL --exit-code 1 .
          """
        }
      }
    }

    stage('Build & Push Image') {
  steps {
    container('kaniko') {
      sh """
        set -e

        mkdir -p /kaniko/.docker

        AWS_ACCOUNT_ID=744804011934
        AWS_REGION=eu-west-1
        ECR_REGISTRY=\${AWS_ACCOUNT_ID}.dkr.ecr.\${AWS_REGION}.amazonaws.com

        aws ecr get-login-password --region \$AWS_REGION > /tmp/token

        cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "\${ECR_REGISTRY}": {
      "username": "AWS",
      "password": "$(cat /tmp/token)"
    }
  }
}
EOF

        /kaniko/executor \
          --context=/home/jenkins/agent/workspace/frontend-pipeline \
          --dockerfile=apps/frontend/Dockerfile \
          --destination=\${ECR_REPO}:${IMAGE_TAG} \
          --verbosity=info
      """
    }
  }
}

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          sh """
            kubectl set image deployment/frontend \
              frontend=${ECR_REPO}:${IMAGE_TAG} \
              -n ${NAMESPACE}

            kubectl rollout status deployment/frontend \
              -n ${NAMESPACE}
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline Success: Trivy + Build + Deploy completed!"
    }

    failure {
      echo "❌ Pipeline Failed"
    }
  }
}