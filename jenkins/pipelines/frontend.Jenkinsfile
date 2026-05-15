pipeline {
    agent {
        kubernetes {
            inheritFrom 'jenkins'

            /*
            ============================================================
            PHASE 1 IMPROVEMENT
            ------------------------------------------------------------
            REMOVED HARDCODED VALUES FROM POD YAML

            OLD:
            value: eu-west-1

            NEW:
            value: ${params.AWS_REGION}

            Now AWS region becomes dynamic and reusable
            across all AWS accounts and regions.
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

      # =========================================================
      # DYNAMIC AWS REGION
      # =========================================================
      env:
        - name: AWS_REGION
          value: "${params.AWS_REGION}"

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
    ================================================================
    PHASE 1 IMPROVEMENT
    ----------------------------------------------------------------
    ALL HARDCODED VALUES REMOVED

    OLD:
    AWS_REGION     = "eu-west-1"
    AWS_ACCOUNT_ID = "744804011934"
    ECR_REPO       = "frontend"
    NAMESPACE      = "app"

    NEW:
    Everything comes dynamically from Jenkins Parameters.
    ================================================================
    */

    parameters {

        /*
        ============================================================
        AWS REGION PARAMETER
        ------------------------------------------------------------
        User can deploy in ANY AWS REGION now.
        ============================================================
        */
        string(
            name: 'AWS_REGION',
            defaultValue: 'eu-west-1',
            description: 'AWS Region'
        )

        /*
        ============================================================
        ECR REPOSITORY PARAMETER
        ------------------------------------------------------------
        No hardcoded frontend/backend repository anymore.
        ============================================================
        */
        string(
            name: 'ECR_REPO',
            defaultValue: 'frontend',
            description: 'ECR Repository Name'
        )

        /*
        ============================================================
        KUBERNETES NAMESPACE PARAMETER
        ------------------------------------------------------------
        Namespace is now configurable.
        ============================================================
        */
        string(
            name: 'NAMESPACE',
            defaultValue: 'app',
            description: 'Kubernetes Namespace'
        )

        /*
        ============================================================
        DEPLOYMENT NAME PARAMETER
        ------------------------------------------------------------
        Makes deployment reusable for frontend/backend/etc.
        ============================================================
        */
        string(
            name: 'DEPLOYMENT_NAME',
            defaultValue: 'frontend',
            description: 'Kubernetes Deployment Name'
        )

        /*
        ============================================================
        CONTAINER NAME PARAMETER
        ------------------------------------------------------------
        Removes hardcoded container name.
        ============================================================
        */
        string(
            name: 'CONTAINER_NAME',
            defaultValue: 'frontend',
            description: 'Container Name Inside Deployment'
        )

        /*
        ============================================================
        DOCKER CONTEXT PARAMETER
        ------------------------------------------------------------
        Makes Jenkinsfile reusable for ANY application.
        ============================================================
        */
        string(
            name: 'DOCKER_CONTEXT',
            defaultValue: 'apps/frontend',
            description: 'Docker Build Context'
        )

        /*
        ============================================================
        DOCKERFILE PATH PARAMETER
        ------------------------------------------------------------
        Dynamic Dockerfile path.
        ============================================================
        */
        string(
            name: 'DOCKERFILE_PATH',
            defaultValue: 'apps/frontend/Dockerfile',
            description: 'Dockerfile Path'
        )
    }

    environment {

        /*
        ============================================================
        DYNAMIC VALUES FROM JENKINS PARAMETERS
        ============================================================
        */

        AWS_REGION     = "${params.AWS_REGION}"
        ECR_REPO       = "${params.ECR_REPO}"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        NAMESPACE      = "${params.NAMESPACE}"
        DEPLOYMENT_NAME = "${params.DEPLOYMENT_NAME}"
        CONTAINER_NAME  = "${params.CONTAINER_NAME}"

        /*
        ============================================================
        PHASE 1 MAJOR IMPROVEMENT
        ------------------------------------------------------------
        REMOVED HARDCODED AWS ACCOUNT ID

        OLD:
        AWS_ACCOUNT_ID = "744804011934"

        NEW:
        Dynamically detected during runtime using AWS CLI.
        ============================================================
        */
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /*
        ============================================================
        NEW STAGE
        ------------------------------------------------------------
        DYNAMIC AWS ACCOUNT DETECTION

        This makes project portable across:
        - Personal AWS accounts
        - Company AWS accounts
        - Any AWS account globally
        ============================================================
        */

        stage('Detect AWS Account ID') {
            steps {
                container('kaniko') {
                    sh '''
                        set -e

                        echo "=================================="
                        echo "Detecting AWS Account ID"
                        echo "=================================="

                        export AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                          --query Account \
                          --output text)

                        echo "Detected AWS Account ID:"
                        echo $AWS_ACCOUNT_ID

                        echo "=================================="

                        echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID" > account.env
                    '''
                }
            }
        }

        stage('Trivy Security Scan') {
            steps {
                container('trivy') {
                    sh '''
                        echo "=============================="
                        echo "Running Trivy Scan"
                        echo "=============================="

                        trivy fs \
                          --severity HIGH,CRITICAL \
                          --scanners vuln \
                          --exit-code 0 \
                          .

                        echo "=============================="
                        echo "Scan completed"
                        echo "=============================="
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                container('kaniko') {

                    sh '''
                        set -e

                        source account.env

                        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

                        echo "=============================="
                        echo "Using Repo:"
                        echo "$FULL_ECR_REPO"
                        echo "=============================="

                        mkdir -p /kaniko/.docker

                        cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com": {}
  }
}
EOF

                        echo "=============================="
                        echo "Building & Pushing Image"
                        echo "=============================="

                        /kaniko/executor \
                          --context=/home/jenkins/agent/workspace/frontend-pipeline/${DOCKER_CONTEXT} \
                          --dockerfile=/home/jenkins/agent/workspace/frontend-pipeline/${DOCKERFILE_PATH} \
                          --destination=${FULL_ECR_REPO}:${IMAGE_TAG} \
                          --destination=${FULL_ECR_REPO}:latest \
                          --cache=true \
                          --verbosity=info
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {

                    sh '''
                        set -e

                        source account.env

                        export FULL_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

                        echo "=============================="
                        echo "Deploying Application"
                        echo "=============================="

                        echo "Deployment Name:"
                        echo "${DEPLOYMENT_NAME}"

                        echo "Container Name:"
                        echo "${CONTAINER_NAME}"

                        echo "Namespace:"
                        echo "${NAMESPACE}"

                        echo "Image:"
                        echo "${FULL_ECR_REPO}:${IMAGE_TAG}"

                        echo "=============================="

                        kubectl set image deployment/${DEPLOYMENT_NAME} \
                          ${CONTAINER_NAME}=${FULL_ECR_REPO}:${IMAGE_TAG} \
                          -n ${NAMESPACE}

                        kubectl rollout status deployment/${DEPLOYMENT_NAME} \
                          -n ${NAMESPACE}
                    '''
                }
            }
        }
    }

    post {

        success {
            echo "✅ Frontend Pipeline Completed Successfully"
        }

        failure {
            echo "❌ Frontend Pipeline Failed"
        }
    }
}