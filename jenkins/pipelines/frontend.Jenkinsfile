pipeline {

    /*
    ============================================================
    GLOBAL PIPELINE OPTIONS
    ============================================================
    */

    options {

        buildDiscarder(
            logRotator(
                numToKeepStr: '20'
            )
        )

        timestamps()
    }

    /*
    ============================================================
    KUBERNETES AGENT
    ============================================================
    */

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

    - name: trivy
      image: aquasec/trivy:latest

      command:
        - cat

      tty: true

      volumeMounts:
        - mountPath: /home/jenkins/agent
          name: workspace-volume

    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug

      command:
        - cat

      tty: true

      envFrom:
        - secretRef:
            name: aws-credentials

      volumeMounts:
        - mountPath: /home/jenkins/agent
          name: workspace-volume

    - name: kubectl
      image: bitnami/kubectl:latest

      command:
        - cat

      tty: true

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

    /*
    ============================================================
    PIPELINE PARAMETERS
    ------------------------------------------------------------
    ENVIRONMENT:
    - dev
    - staging
    - prod

    APP_NAME:
    - frontend
    - backend
    - future apps
    ============================================================
    */

    parameters {

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select Deployment Environment'
        )

        choice(
            name: 'APP_NAME',
            choices: ['frontend', 'backend'],
            description: 'Application To Deploy'
        )
    }

    /*
    ============================================================
    GLOBAL ENVIRONMENT VARIABLES
    ============================================================
    */

    environment {

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        /*
        ============================================================
        CHECKOUT SOURCE CODE
        ============================================================
        */

        stage('Checkout') {

            steps {

                script {

                    currentBuild.displayName =
                        "#${BUILD_NUMBER} - ${params.ENVIRONMENT} - ${params.APP_NAME}"
                }

                checkout scm
            }
        }

        /*
        ============================================================
        LOAD ENVIRONMENT CONFIG
        ============================================================
        */

        stage('Load Environment Config') {

            steps {

                container('kaniko') {

                    sh '''
                        set -e

                        echo "=================================="
                        echo "Loading Environment Configuration"
                        echo "=================================="

                        export ENVIRONMENT=${ENVIRONMENT}

                        chmod +x scripts/load-env.sh

                        . scripts/load-env.sh

                        echo ""
                        echo "Environment Loaded Successfully"
                        echo ""
                    '''
                }
            }
        }

        /*
        ============================================================
        DYNAMIC APPLICATION CONFIGURATION
        ------------------------------------------------------------
        THIS IS THE MOST IMPORTANT PHASE 4 CHANGE
        ------------------------------------------------------------

        Dynamically builds:
        - ECR repo
        - deployment
        - container
        - docker context
        - dockerfile

        based on APP_NAME parameter.

        SAME PIPELINE NOW WORKS FOR:
        - frontend
        - backend
        - future services
        ============================================================
        */

        stage('Load Application Config') {

            steps {

                script {

                    env.APP_ECR_REPO =
                        sh(
                            script: """
                                . scripts/load-env.sh >/dev/null 2>&1

                                eval echo \\$${params.APP_NAME.toUpperCase()}_ECR_REPO
                            """,
                            returnStdout: true
                        ).trim()

                    env.APP_DEPLOYMENT =
                        sh(
                            script: """
                                . scripts/load-env.sh >/dev/null 2>&1

                                eval echo \\$${params.APP_NAME.toUpperCase()}_DEPLOYMENT
                            """,
                            returnStdout: true
                        ).trim()

                    env.APP_CONTAINER =
                        sh(
                            script: """
                                . scripts/load-env.sh >/dev/null 2>&1

                                eval echo \\$${params.APP_NAME.toUpperCase()}_CONTAINER
                            """,
                            returnStdout: true
                        ).trim()

                    env.APP_DOCKER_CONTEXT =
                        sh(
                            script: """
                                . scripts/load-env.sh >/dev/null 2>&1

                                eval echo \\$${params.APP_NAME.toUpperCase()}_DOCKER_CONTEXT
                            """,
                            returnStdout: true
                        ).trim()

                    env.APP_DOCKERFILE =
                        sh(
                            script: """
                                . scripts/load-env.sh >/dev/null 2>&1

                                eval echo \\$${params.APP_NAME.toUpperCase()}_DOCKERFILE
                            """,
                            returnStdout: true
                        ).trim()

                    echo "=================================="
                    echo "Application Configuration Loaded"
                    echo "=================================="

                    echo "APP_NAME: ${params.APP_NAME}"
                    echo "APP_ECR_REPO: ${env.APP_ECR_REPO}"
                    echo "APP_DEPLOYMENT: ${env.APP_DEPLOYMENT}"
                    echo "APP_CONTAINER: ${env.APP_CONTAINER}"
                    echo "APP_DOCKER_CONTEXT: ${env.APP_DOCKER_CONTEXT}"
                    echo "APP_DOCKERFILE: ${env.APP_DOCKERFILE}"

                    echo "=================================="
                }
            }
        }

        /*
        ============================================================
        DYNAMIC AWS ACCOUNT DETECTION
        ============================================================
        */

        stage('Detect AWS Account ID') {

            steps {

                container('kaniko') {

                    script {

                        env.AWS_ACCOUNT_ID = sh(
                            script: '''
                                aws sts get-caller-identity \
                                --query Account \
                                --output text
                            ''',
                            returnStdout: true
                        ).trim()

                        echo "=================================="
                        echo "Detected AWS Account ID"
                        echo "=================================="

                        echo "${env.AWS_ACCOUNT_ID}"

                        echo "=================================="
                    }
                }
            }
        }

        /*
        ============================================================
        TRIVY SECURITY SCAN
        ============================================================
        */

        stage('Trivy Security Scan') {

            steps {

                container('trivy') {

                    sh '''
                        set -e

                        echo "=================================="
                        echo "Running Trivy Security Scan"
                        echo "=================================="

                        trivy fs \
                          --severity HIGH,CRITICAL \
                          --scanners vuln \
                          --exit-code 0 \
                          .

                        echo ""
                        echo "Trivy Scan Completed"
                        echo "=================================="
                    '''
                }
            }
        }

        /*
        ============================================================
        BUILD & PUSH IMAGE
        ============================================================
        */

        stage('Build & Push Image') {

            steps {

                container('kaniko') {

                    sh '''
                        set -e

                        . scripts/load-env.sh

                        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_ECR_REPO}"

                        echo "=================================="
                        echo "Using ECR Repository"
                        echo "=================================="

                        echo "$FULL_ECR_REPO"

                        mkdir -p /kaniko/.docker

                        cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": {}
  }
}
EOF

                        echo "=================================="
                        echo "Building & Pushing Docker Image"
                        echo "=================================="

                        /kaniko/executor \
                          --context=/home/jenkins/agent/workspace/frontend-pipeline/${APP_DOCKER_CONTEXT} \
                          --dockerfile=/home/jenkins/agent/workspace/frontend-pipeline/${APP_DOCKERFILE} \
                          --destination=${FULL_ECR_REPO}:${IMAGE_TAG} \
                          --destination=${FULL_ECR_REPO}:latest \
                          --cache=true \
                          --verbosity=info
                    '''
                }
            }
        }

        /*
        ============================================================
        DEPLOY TO KUBERNETES
        ============================================================
        */

        stage('Deploy to Kubernetes') {

            steps {

                container('kubectl') {

                    timeout(time: 10, unit: 'MINUTES') {

                        sh '''
                            set -e

                            . scripts/load-env.sh

                            export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_ECR_REPO}"

                            echo "=================================="
                            echo "Deploying Application"
                            echo "=================================="

                            echo "Environment: $ENVIRONMENT"
                            echo "Application: ${APP_NAME}"

                            echo "Namespace: $APP_NAMESPACE"

                            echo "Deployment: ${APP_DEPLOYMENT}"

                            echo "Container: ${APP_CONTAINER}"

                            echo "Image: ${FULL_ECR_REPO}:${IMAGE_TAG}"

                            echo "=================================="

                            kubectl set image deployment/${APP_DEPLOYMENT} \
                              ${APP_CONTAINER}=${FULL_ECR_REPO}:${IMAGE_TAG} \
                              -n ${APP_NAMESPACE}

                            kubectl rollout status deployment/${APP_DEPLOYMENT} \
                              -n ${APP_NAMESPACE}
                        '''
                    }
                }
            }
        }
    }

    /*
    ============================================================
    POST ACTIONS
    ============================================================
    */

    post {

        success {

            echo "✅ Pipeline Completed Successfully"
        }

        failure {

            echo "❌ Pipeline Failed"
        }

        always {

            echo "=================================="
            echo "Pipeline Execution Finished"
            echo "=================================="
        }
    }
}