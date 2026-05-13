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

  - name: sonar
    image: sonarsource/sonar-scanner-cli:latest
    tty: true
    command:
    - cat
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    tty: true
    command:
    - cat
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
    command:
    - cat
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

    stage('SonarQube Analysis') {
      steps {
        container('sonar') {

          withSonarQubeEnv('sonarqube') {

            withCredentials([
              string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')
            ]) {

              sh '''
                echo "=================================="
                echo "Testing SonarQube Connectivity"
                echo "=================================="

                echo "SONAR_HOST_URL=$SONAR_HOST_URL"

                curl -u $SONAR_TOKEN: \
                  $SONAR_HOST_URL/api/system/status

                echo ""
                echo "=================================="
                echo "Running SonarQube Analysis"
                echo "=================================="

                sonar-scanner \
                  -Dsonar.projectKey=frontend \
                  -Dsonar.projectName=frontend \
                  -Dsonar.sources=apps/frontend/src \
                  -Dsonar.host.url=$SONAR_HOST_URL \
                  -Dsonar.login=$SONAR_TOKEN
              '''
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
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
      echo "✅ Pipeline Success: SonarQube + Build + Deploy completed!"
    }

    failure {
      echo "❌ Pipeline Failed"
    }
  }
}