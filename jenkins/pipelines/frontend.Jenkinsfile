   groovy
pipeline {

    agent {
        kubernetes {
            inheritFrom 'jenkins'

            /*
            ============================================================
            PHASE 2 IMPROVEMENT
            ------------------------------------------------------------
            AWS REGION NOW COMES FROM:
            configs/dev.env
            configs/staging.env
            configs/prod.env
            ============================================================
            */

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
    PHASE 2 IMPROVEMENT
    ------------------------------------------------------------
    ONLY ENVIRONMENT SELECTION REMAINS

    Everything else loads automatically from:
    configs/<environment>.env
    ============================================================
    */

    parameters {

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select Deployment Environment'
        )
    }

    environment {

        /*
        ============================================================
        BUILD NUMBER
        ============================================================
        */

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        /*
        ============================================================
        CHECKOUT
        ============================================================
        */

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /*
        ============================================================
        LOAD CENTRALIZED CONFIGURATION
        ------------------------------------------------------------
        Loads:
        configs/dev.env
        configs/staging.env
        configs/prod.env
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

                        source scripts/load-env.sh

                        echo ""
                        echo "Loaded Environment Variables:"
                        echo ""

                        env | grep -E 'AWS_REGION|FRONTEND|APP_NAMESPACE'
                    '''
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

                    sh '''
                        set -e

                        source scripts/load-env.sh

                        echo "=================================="
                        echo "Detecting AWS Account ID"
                        echo "=================================="

                        export AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                          --query Account \
                          --output text)

                        echo ""
                        echo "Detected AWS Account ID:"
                        echo "$AWS_ACCOUNT_ID"

                        echo ""
                        echo "=================================="

                        cat > account.env <<EOF
AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID
EOF
                    '''
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
                        echo "=================================="
                        echo "Running Trivy Security Scan"
                        echo "=================================="

                        trivy fs \
                          --severity HIGH,CRITICAL \
                          --scanners vuln \
                          --exit-code 0 \
                          .

                        echo ""
                        echo "=================================="
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

                        source scripts/load-env.sh
                        source account.env

                        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_ECR_REPO}"

                        echo "=================================="
                        echo "Using ECR Repository"
                        echo "=================================="

                        echo "$FULL_ECR_REPO"

                        echo ""
                        echo "=================================="

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
                          --context=/home/jenkins/agent/workspace/frontend-pipeline/${FRONTEND_DOCKER_CONTEXT} \
                          --dockerfile=/home/jenkins/agent/workspace/frontend-pipeline/${FRONTEND_DOCKERFILE} \
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

                    sh '''
                        set -e

                        source scripts/load-env.sh
                        source account.env

                        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_ECR_REPO}"

                        echo "=================================="
                        echo "Deploying Application"
                        echo "=================================="

                        echo "Environment:"
                        echo "$ENVIRONMENT"

                        echo ""
                        echo "Namespace:"
                        echo "$APP_NAMESPACE"

                        echo ""
                        echo "Deployment:"
                        echo "$FRONTEND_DEPLOYMENT"

                        echo ""
                        echo "Container:"
                        echo "$FRONTEND_CONTAINER"

                        echo ""
                        echo "Image:"
                        echo "${FULL_ECR_REPO}:${IMAGE_TAG}"

                        echo ""
                        echo "=================================="

                        kubectl set image deployment/${FRONTEND_DEPLOYMENT} \
                          ${FRONTEND_CONTAINER}=${FULL_ECR_REPO}:${IMAGE_TAG} \
                          -n ${APP_NAMESPACE}

                        kubectl rollout status deployment/${FRONTEND_DEPLOYMENT} \
                          -n ${APP_NAMESPACE}
                    '''
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

            echo "✅ Frontend Pipeline Completed Successfully"
        }

        failure {

            echo "❌ Frontend Pipeline Failed"
        }
    }
}

