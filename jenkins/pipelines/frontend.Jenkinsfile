pipeline {
    agent any

    environment {
        AWS_REGION = "eu-west-1"
        ECR_REPO = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
        IMAGE_TAG = "latest"
        NAMESPACE = "app"
        PATH = "/var/jenkins_home:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }

    stages {
        stage('Build & Push Image') {
            steps {
                sh """
                kubectl delete pod kaniko-build -n jenkins --ignore-not-found=true

                kubectl run kaniko-build \
                  --image=gcr.io/kaniko-project/executor:latest \
                  --restart=Never \
                  -n jenkins \
                  --overrides='{
                    "spec": {
                      "serviceAccountName": "jenkins",
                      "containers": [{
                        "name": "kaniko-build",
                        "image": "gcr.io/kaniko-project/executor:latest",
                        "args": [
                          "--context=git://MuhammadJaffar52:\$(kubectl get secret github-credentials -n jenkins -o jsonpath={.data.GITHUB_PAT} | base64 -d)@github.com/MuhammadJaffar52/devops-infrastructure#refs/heads/main",
                          "--context-sub-path=apps/frontend",
                          "--dockerfile=Dockerfile",
                          "--destination=${ECR_REPO}:${IMAGE_TAG}",
                          "--verbosity=info"
                        ],
                        "envFrom": [{"secretRef": {"name": "aws-credentials"}}],
                        "env": [
                          {"name": "AWS_REGION", "value": "${AWS_REGION}"},
                          {"name": "AWS_SDK_LOAD_CONFIG", "value": "true"}
                        ]
                      }],
                      "restartPolicy": "Never"
                    }
                  }'

                echo "Waiting for kaniko to complete..."
                kubectl wait pod/kaniko-build -n jenkins \
                  --for=condition=Ready --timeout=30s || true

                kubectl logs kaniko-build -n jenkins -f || true

                kubectl wait pod/kaniko-build -n jenkins \
                  --for=jsonpath='{.status.phase}'=Succeeded --timeout=300s

                kubectl delete pod kaniko-build -n jenkins
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
