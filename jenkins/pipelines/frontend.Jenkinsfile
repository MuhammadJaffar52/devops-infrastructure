
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

                container('kubectl') {

                    script {

                        env.APP_ECR_REPO = sh(
                            script: '''
                                export ENVIRONMENT=dev
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_ECR_REPO
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DEPLOYMENT = sh(
                            script: '''
                                export ENVIRONMENT=dev
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DEPLOYMENT
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_CONTAINER = sh(
                            script: '''
                                export ENVIRONMENT=dev
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_CONTAINER
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DOCKER_CONTEXT = sh(
                            script: '''
                                export ENVIRONMENT=dev
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DOCKER_CONTEXT
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DOCKERFILE = sh(
                            script: '''
                                export ENVIRONMENT=dev
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DOCKERFILE
                            ''',
                            returnStdout: true
                        ).trim()

                        echo "APP_ECR_REPO=${env.APP_ECR_REPO}"
                        echo "APP_DEPLOYMENT=${env.APP_DEPLOYMENT}"
                        echo "APP_CONTAINER=${env.APP_CONTAINER}"
                        echo "APP_DOCKER_CONTEXT=${env.APP_DOCKER_CONTEXT}"
                        echo "APP_DOCKERFILE=${env.APP_DOCKERFILE}"

                        echo "Application configuration loaded successfully"
                    }
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

        stage('Verify ECR Repository') {
            steps {

                container('aws') {

                    sh '''
                        aws ecr describe-repositories \
                        --repository-names ${APP_ECR_REPO} \
                        --region ${AWS_REGION}
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
                        echo "Starting Docker build"

                        mkdir -p /kaniko/.docker

                        cat > /kaniko/.docker/config.json <<EOF
{
  "credsStore": "ecr-login"
}
EOF

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

            kubectl apply -f k8s/apps/frontend/
        '''
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

