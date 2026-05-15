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

// * name: trivy
  image: aquasec/trivy:latest
  command:

  * cat
    tty: true
    volumeMounts:
  * mountPath: /home/jenkins/agent
    name: workspace-volume

* name: kaniko
  image: gcr.io/kaniko-project/executor:debug
  command:

  * cat
    tty: true
    env:
  * name: AWS_REGION
    value: eu-west-1
    envFrom:
  * secretRef:
    name: aws-credentials
    volumeMounts:
  * mountPath: /home/jenkins/agent
    name: workspace-volume

* name: kubectl
  image: bitnami/kubectl:latest
  command:

  * cat
    tty: true
    securityContext:
    runAsUser: 0
    volumeMounts:
  * mountPath: /home/jenkins/agent
    name: workspace-volume

volumes:
- name: workspace-volume
emptyDir: {}
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

        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

        echo "=============================="
        echo "Using Repo: $FULL_ECR_REPO"
        echo "=============================="

        mkdir -p /kaniko/.docker

        cat > /kaniko/.docker/config.json <<EOF


{
"auths": {
"${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": {}
}
}
EOF


        echo "=============================="
        echo "Building & Pushing Image"
        echo "=============================="

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

        echo "Deploying Image: $FULL_ECR_REPO:${IMAGE_TAG}"

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
