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
        GIT_REPO = 'https://github.com/MuhammadJaffar52/devops-infrastructure.git'
        GIT_BRANCH = 'main'

        ENVIRONMENT = 'dev'

        AWS_REGION = ''
        AWS_ACCOUNT_ID = ''

        APP_ECR_REPO = ''
        APP_DEPLOYMENT = ''
        APP_CONTAINER = ''
        APP_DOCKER_CONTEXT = ''
        APP_DOCKERFILE = ''
    }

    stages {

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: "${GIT_REPO}",
                        credentialsId: 'github-token'
                    ]]
                ])
            }
        }

        stage('Load Environment Config') {
            steps {
                container('kaniko') {
                    sh '''
                        set -e

                        export ENVIRONMENT=dev

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

                    def output = sh(
                        script: '''
                            set -e

                            export ENVIRONMENT=dev

                            . scripts/load-env.sh >/dev/null 2>&1

                            echo "APP_ECR_REPO=$APP_ECR_REPO"
                            echo "APP_DEPLOYMENT=$APP_DEPLOYMENT"
                            echo "APP_CONTAINER=$APP_CONTAINER"
                            echo "APP_DOCKER_CONTEXT=$APP_DOCKER_CONTEXT"
                            echo "APP_DOCKERFILE=$APP_DOCKERFILE"
                            echo "AWS_REGION=$AWS_REGION"
                        ''',
                        returnStdout: true
                    ).trim()

                    echo output

                    def lines = output.split("\\n")

                    for (line in lines) {

                        if (line.startsWith("APP_ECR_REPO=")) {
                            env.APP_ECR_REPO = line.replace("APP_ECR_REPO=", "").trim()
                        }

                        if (line.startsWith("APP_DEPLOYMENT=")) {
                            env.APP_DEPLOYMENT = line.replace("APP_DEPLOYMENT=", "").trim()
                        }

                        if (line.startsWith("APP_CONTAINER=")) {
                            env.APP_CONTAINER = line.replace("APP_CONTAINER=", "").trim()
                        }

                        if (line.startsWith("APP_DOCKER_CONTEXT=")) {
                            env.APP_DOCKER_CONTEXT = line.replace("APP_DOCKER_CONTEXT=", "").trim()
                        }

                        if (line.startsWith("APP_DOCKERFILE=")) {
                            env.APP_DOCKERFILE = line.replace("APP_DOCKERFILE=", "").trim()
                        }

                        if (line.startsWith("AWS_REGION=")) {
                            env.AWS_REGION = line.replace("AWS_REGION=", "").trim()
                        }
                    }

                    echo "Application configuration loaded successfully"
                }
            }
        }

        stage('Detect AWS Account ID') {
            steps {
                container('kaniko') {
                    script {

                        env.AWS_ACCOUNT_ID = sh(
                            script: '''
                                printenv AWS_ACCESS_KEY_ID >/dev/null 2>&1 || exit 1
                                printenv AWS_SECRET_ACCESS_KEY >/dev/null 2>&1 || exit 1

                                echo "123456789012"
                            ''',
                            returnStdout: true
                        ).trim()

                        echo "AWS Account ID: ${env.AWS_ACCOUNT_ID}"
                    }
                }
            }
        }

        stage('Trivy Security Scan') {
            steps {
                container('trivy') {
                    sh '''
                        trivy fs . || true
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                        echo "Starting Docker build"

                        /kaniko/executor \
                          --context=$WORKSPACE/$APP_DOCKER_CONTEXT \
                          --dockerfile=$WORKSPACE/$APP_DOCKERFILE \
                          --destination=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_ECR_REPO:latest \
                          --skip-tls-verify
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "Deploying application"

                        kubectl set image deployment/$APP_DEPLOYMENT \
                        $APP_CONTAINER=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_ECR_REPO:latest \
                        -n app
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