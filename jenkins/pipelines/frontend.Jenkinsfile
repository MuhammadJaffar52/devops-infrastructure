pipeline {
    agent any

    environment {
        AWS_REGION = "eu-west-1"
        ECR_REPO = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
        IMAGE_TAG = "latest"
        NAMESPACE = "app"
    }

    stages {
        stage('Build & Push Image') {
            steps {
                sh """
                kubectl run kaniko-build \
                  --image=gcr.io/kaniko-project/executor:latest \
                  --restart=Never \
                  --rm \
                  -n jenkins \
                  --env="AWS_REGION=${AWS_REGION}" \
                  --overrides='{
                    "spec": {
                      "serviceAccountName": "jenkins",
                      "containers": [{
                        "name": "kaniko-build",
                        "image": "gcr.io/kaniko-project/executor:latest",
                        "args": [
                          "--context=git://github.com/MuhammadJaffar52/devops-infrastructure#refs/heads/main",
                          "--context-sub-path=apps/frontend",
                          "--dockerfile=Dockerfile",
                          "--destination=${ECR_REPO}:${IMAGE_TAG}"
                        ],
                        "env": [
                          {"name": "AWS_REGION", "value": "${AWS_REGION}"},
                          {"name": "AWS_SDK_LOAD_CONFIG", "value": "true"}
                        ]
                      }],
                      "restartPolicy": "Never"
                    }
                  }' \
                  --timeout=300s \
                  -i
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/frontend \
                  frontend=${ECR_REPO}:${IMAGE_TAG} \
                  -n ${NAMESPACE}

                kubectl rollout status deployment/frontend -n ${NAMESPACE}
                """
            }
        }
    }

    post {
        success { echo "✅ Frontend deployed successfully!" }
        failure { echo "❌ Deployment failed" }
    }
}