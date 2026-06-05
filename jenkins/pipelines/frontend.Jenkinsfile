pipeline {

    agent {
        kubernetes {

            yaml """
apiVersion: v1
kind: Pod

metadata:
  labels:
    app: generic-app-pipeline

spec:
  serviceAccountName: jenkins

  containers:

    - name: trivy
      image: aquasec/trivy:0.66.0
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

        IMAGE_TAG = "${BUILD_NUMBER}"
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

                        export ENVIRONMENT=${ENVIRONMENT}

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

                        env.AWS_REGION = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $AWS_REGION
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_NAME = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_NAME
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_ECR_REPO = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_ECR_REPO
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DEPLOYMENT = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DEPLOYMENT
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_CONTAINER = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_CONTAINER
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_NAMESPACE = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_NAMESPACE
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DOCKER_CONTEXT = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DOCKER_CONTEXT
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_DOCKERFILE = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_DOCKERFILE
                            ''',
                            returnStdout: true
                        ).trim()

                        env.APP_K8S_PATH = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $APP_K8S_PATH
                            ''',
                            returnStdout: true
                        ).trim()

                        env.TRIVY_SEVERITY = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $TRIVY_SEVERITY
                            ''',
                            returnStdout: true
                        ).trim()

                        env.TRIVY_EXIT_CODE = sh(
                            script: '''
                                export ENVIRONMENT=${ENVIRONMENT}
                                . scripts/load-env.sh >/dev/null 2>&1
                                echo -n $TRIVY_EXIT_CODE
                            ''',
                            returnStdout: true
                        ).trim()

                        echo "======================================"
                        echo " APPLICATION CONFIGURATION"
                        echo "======================================"

                        echo "ENVIRONMENT=${env.ENVIRONMENT}"
                        echo "AWS_REGION=${env.AWS_REGION}"
                        echo "APP_NAME=${env.APP_NAME}"
                        echo "APP_ECR_REPO=${env.APP_ECR_REPO}"
                        echo "APP_DEPLOYMENT=${env.APP_DEPLOYMENT}"
                        echo "APP_CONTAINER=${env.APP_CONTAINER}"
                        echo "APP_NAMESPACE=${env.APP_NAMESPACE}"
                        echo "APP_DOCKER_CONTEXT=${env.APP_DOCKER_CONTEXT}"
                        echo "APP_DOCKERFILE=${env.APP_DOCKERFILE}"
                        echo "APP_K8S_PATH=${env.APP_K8S_PATH}"
                        echo "IMAGE_TAG=${env.IMAGE_TAG}"
                        echo "TRIVY_SEVERITY=${env.TRIVY_SEVERITY}"
                        echo "TRIVY_EXIT_CODE=${env.TRIVY_EXIT_CODE}"

                        echo "======================================"

                        if (!env.APP_ECR_REPO?.trim()) {
                            error("APP_ECR_REPO is missing")
                        }

                        if (!env.APP_DEPLOYMENT?.trim()) {
                            error("APP_DEPLOYMENT is missing")
                        }

                        if (!env.APP_CONTAINER?.trim()) {
                            error("APP_CONTAINER is missing")
                        }

                        if (!env.APP_DOCKER_CONTEXT?.trim()) {
                            error("APP_DOCKER_CONTEXT is missing")
                        }

                        if (!env.APP_DOCKERFILE?.trim()) {
                            error("APP_DOCKERFILE is missing")
                        }

                        if (!env.APP_K8S_PATH?.trim()) {
                            error("APP_K8S_PATH is missing")
                        }

                        if (!env.TRIVY_SEVERITY?.trim()) {
                            error("TRIVY_SEVERITY is missing")
                        }

                        if (!env.TRIVY_EXIT_CODE?.trim()) {
                            error("TRIVY_EXIT_CODE is missing")
                        }

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
                        set -e

                        echo "======================================"
                        echo "TRIVY SECURITY SCAN"
                        echo "======================================"

                        mkdir -p reports

                        trivy fs \
                          --severity ${TRIVY_SEVERITY} \
                          --exit-code ${TRIVY_EXIT_CODE} \
                          --no-progress \
                          --format table \
                          --output reports/trivy-report.txt \
                          ${WORKSPACE}/${APP_DOCKER_CONTEXT}

                        echo ""
                        echo "========= TRIVY REPORT ========="
                        cat reports/trivy-report.txt
                        echo "==============================="
                    '''
                }
            }

            post {
                always {
                    archiveArtifacts artifacts: 'reports/trivy-report.txt', allowEmptyArchive: true
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
                          --destination=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_ECR_REPO}:latest \
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

                        kubectl apply -n ${APP_NAMESPACE} -f ${APP_K8S_PATH}

                        kubectl rollout restart deployment/${APP_DEPLOYMENT} \
                          -n ${APP_NAMESPACE}

                        kubectl rollout status deployment/${APP_DEPLOYMENT} \
                          -n ${APP_NAMESPACE}
                    '''
                }
            }
        }
    }

    post {

        always {

            echo '======================================'
            echo 'Pipeline execution finished'
            echo '======================================'
        }

        success {

            echo 'Pipeline completed successfully'
        }

        failure {

            echo 'Pipeline failed'
        }
    }
}