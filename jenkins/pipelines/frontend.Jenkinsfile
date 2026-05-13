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
    command: ["sleep"]
    args: ["9999999"]
    env:
    - name: AWS_REGION
      value: eu-west-1
    envFrom:
    - secretRef:
        name: aws-credentials

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep"]
    args: ["9999999"]
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
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /* ---------------- SONARQUBE STAGE ---------------- */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh """
                    echo "Running SonarQube analysis..."
                    sonar-scanner \
                      -Dsonar.projectKey=frontend \
                      -Dsonar.sources=apps/frontend \
                      -Dsonar.host.url=http://sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                      -Dsonar.login=\$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* ---------------- BUILD IMAGE ---------------- */
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

        /* ---------------- DEPLOY ---------------- */
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
        success {
            echo "✅ Pipeline Success: SonarQube + Build + Deploy completed!"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}