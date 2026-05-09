pipeline {
    agent any

    environment {
        AWS_REGION = "eu-west-1"
        ECR_REPO = "744804011934.dkr.ecr.eu-west-1.amazonaws.com/frontend"
        IMAGE_TAG = "latest"
        CLUSTER = "devops-cluster"
        NAMESPACE = "app"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh """
                cd apps/frontend
                docker build -t $ECR_REPO:$IMAGE_TAG .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REPO
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                docker push $ECR_REPO:$IMAGE_TAG
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/frontend \
                frontend=$ECR_REPO:$IMAGE_TAG \
                -n $NAMESPACE

                kubectl rollout status deployment/frontend -n $NAMESPACE
                """
            }
        }
    }

    post {
        success {
            echo "✅ Frontend deployed successfully!"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}