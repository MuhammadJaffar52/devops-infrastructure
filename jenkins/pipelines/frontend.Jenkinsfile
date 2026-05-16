
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod

metadata:
  labels:
    app: frontend-pipeline

spec:
  serviceAccountName: jenkins

  containers:

    - name: trivy
      image: aquasec/trivy:latest
      command:
        - cat
      tty: true

    - name: aws
      image: amazon/aws-cli:latest
      command:
        - cat
      tty: true
      envFrom:
        - secretRef:
            name: aws-credentials

    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - cat
      tty: true
      envFrom:
        - secretRef:
            name: aws-credentials

    - name: kubectl
      image: bitnami/kubectl:latest
      command:
        - cat
      tty: true
      securityContext:
        runAsUser: 0
"""
        }
    }

    environment {
        ENVIRONMENT = "dev"
        AWS_REGION = "eu-west-1"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Load Environment Config') {
            steps {
                container('kubectl') {
                    sh '''
                        set -e

                        chmod +x scripts/load-env.sh
                        sh scripts/load-env.sh

                        echo "Environment configuration loaded"
                    '''
                }
            }
        }

        stage('Load Application Config') {
            steps {
                script {

                    def appConfig = sh(
                        script: '''
                            set -e

                            export ENVIRONMENT=dev
                            . scripts/load-env.sh >/dev/null 2>&1

                            echo "APP_ECR_REPO=$APP_ECR_REPO"
                            echo "APP_DEPLOYMENT=$APP_DEPLOYMENT"
                            echo "APP_CONTAINER=$APP_CONTAINER"
                            echo "APP_DOCKER_CONTEXT=$APP_DOCKER_CONTEXT"
                            echo "APP_DOCKERFILE=$APP_DOCKERFILE"
                        ''',
                        returnStdout: true
                    ).trim()

                    echo appConfig

                    appConfig.split("\\n").each { line ->

                        def parts = line.tokenize("=")

                        if (parts.size() >= 2) {

                            env[parts[0]] = parts[1]
                        }
                    }

                    echo "Application configuration loaded successfully"
                }
            }
        }

        stage('Detect AWS Account ID') {
            steps {

                container('aws') {

                    script {

                        env.AWS_ACCOUNT_ID = sh(
                            script: '''
                                aws sts get-caller-identity \
                                --query Account \
                                --output text
                            ''',
                            returnStdout: true
                        ).trim()

                        echo "AWS Account ID: ${env.AWS_ACCOUNT_ID}"
                    }
                }
            }
        }

        stage('Login To Amazon ECR') {
            steps {

                container('aws') {

                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} > /tmp/ecr-token
                    '''
                }
            }
        }

        stage('Trivy Security Scan') {
            steps {

                container('trivy') {

                    sh '''
                        trivy fs .
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {

                container('kaniko') {

                    sh '''
                        mkdir -p /kaniko/.docker

                        cat > /kaniko/.docker/config.json <<EOF
{
  "credHelpers": {
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": "ecr-login"
  }
}
EOF

                        echo "Starting Docker build"

                        /kaniko/executor \
                          --context=${WORKSPACE}/${APP_DOCKER_CONTEXT} \
                          --dockerfile=${WORKSPACE}/${APP_DOCKERFILE} \
                          --destination=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_ECR_REPO}:${IMAGE_TAG} \
                          --skip-tls-verify
                    '''
                }
            }
        }

        stage('Deploy To Kubernetes') {
            steps {

                container('kubectl') {

                    sh '''
                        echo "Deploying application"

                        kubectl apply -f k8s/frontend/
                    '''
                }
            }
        }
    }

    post {

        always {
            echo 'Pipeline execution finished'
        }

        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}

