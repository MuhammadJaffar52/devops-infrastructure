pipeline {
    agent {
        kubernetes {
            label 'kaniko-agent'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  namespace: jenkins
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - 9999999
    env:
    - name: AWS_REGION
      value: eu-west-1
    - name: AWS_SDK_LOAD_CONFIG
      value: "true"
    envFrom:
    - secretRef:
        name: aws-credentials
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - sleep
    args:
    - 9999999
    securityContext:
      runAsUser: 0
"""
        }
    }

    environment {
        AWS_REGION = "eu-west-1"
        ECR_REPO = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
        IMAGE_TAG = "latest"
        NAMESPACE = "app"
        GITHUB_PAT = "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"
    }

    stages {
        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                      --context=git://MuhammadJaffar52:${GITHUB_PAT}@github.com/MuhammadJaffar52/devops-infrastructure#refs/heads/main \
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
                    kubectl rollout status deployment/frontend -n ${NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success { echo "✅ Frontend deployed successfully!" }
        failure { echo "❌ Deployment failed" }
    }
}
