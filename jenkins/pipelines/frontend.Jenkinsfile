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
  dnsPolicy: ClusterFirst

  containers:

  - name: trivy
    image: aquasec/trivy:latest
    tty: true
    command: ["cat"]
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    tty: true
    command: ["cat"]
    env:
    - name: AWS_REGION
      value: eu-west-1
    envFrom:
    - secretRef:
        name: aws-credentials
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume

  - name: kubectl
    image: bitnami/kubectl:latest
    tty: true
    command: ["cat"]
    securityContext:
      runAsUser: 0
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume

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

    stage('Trivy Security Scan') {
      steps {
        container('trivy') {
          sh '''
            echo "=============================="
            echo "Running Trivy Scan"
            echo "=============================="

            trivy fs --severity HIGH,CRITICAL /home/jenkins/agent/workspace/frontend-pipeline || true

            echo "Scan completed (non-blocking mode)"
          '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context=git://github.com/MuhammadJaffar52/devops-infrastructure.git#refs/heads/main \
              --context-sub-path=apps/frontend \
              --dockerfile=Dockerfile \
              --destination=${ECR_REPO}:${IMAGE_TAG} \
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
      echo "✅ Pipeline completed (Trivy + Build + Deploy)"
    }

    failure {
      echo "❌ Pipeline Failed"
    }
  }
}