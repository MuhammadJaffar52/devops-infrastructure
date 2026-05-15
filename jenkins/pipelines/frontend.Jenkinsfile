pipeline {
  agent {
    kubernetes {
      inheritFrom 'jenkins'
      yaml """
# pod yaml
"""
    }
  }

  environment {
    AWS_REGION     = "eu-west-1"
    AWS_ACCOUNT_ID = "744804011934"
    ECR_REPO       = "frontend"
    IMAGE_TAG      = "${BUILD_NUMBER}"
    NAMESPACE      = "app"
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
            trivy fs \
              --severity HIGH,CRITICAL \
              --scanners vuln \
              --exit-code 0 \
              .
          '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh '''
            set -e

            export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

            echo "Using Repo: $FULL_ECR_REPO"

            mkdir -p /kaniko/.docker

            cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": {}
  }
}
EOF

            /kaniko/executor \
              --context=/home/jenkins/agent/workspace/frontend-pipeline/apps/frontend \
              --dockerfile=/home/jenkins/agent/workspace/frontend-pipeline/apps/frontend/Dockerfile \
              --destination=${FULL_ECR_REPO}:${IMAGE_TAG} \
              --destination=${FULL_ECR_REPO}:latest \
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
            set -e

            export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

            kubectl set image deployment/frontend \
              frontend=${FULL_ECR_REPO}:${IMAGE_TAG} \
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