pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'taye97/pythonapp2' 
        TAG = "${BUILD_NUMBER}"
    }

    stages {
        
        stage('Branch Name') {
            steps {
                echo "This is branch: ${env.BRANCH_NAME}"  
            }
        }

        
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image for branch: ${env.BRANCH_NAME}"
                    
                    sh """docker build -t ${DOCKER_IMAGE}:${env.BRANCH_NAME} ."""
                }
            }
        }

        
        stage('Snyk Scan') {
            steps {
                script {
                    echo "Scanning Docker image for vulnerabilities..."
                    
                    sh 'snyk test --docker ${DOCKER_IMAGE}:${env.BRANCH_NAME} --file=Dockerfile'
                }
            }
        }

        
        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'testing') {
                        echo "Deploying to TESTING environment..."
                        
                        sh 'docker-compose -f docker-compose.testing.yml up -d'
                    } else if (env.BRANCH_NAME == 'staging') {
                        echo "Deploying to STAGING environment..."
                    
                        sh 'docker-compose -f docker-compose.staging.yml up -d'
                    } else if (env.BRANCH_NAME == 'main') {
                        echo "Deploying to PRODUCTION environment..."
                        
                        sh 'docker-compose up -d'
                    } else {
                        echo "Branch ${env.BRANCH_NAME} does not have a deployment configured."
                    }
                }
            }
        }
    }
}
