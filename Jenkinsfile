def image = null

pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'taye97/pythonapp2'
        TAG = "${BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
        VM_IP = '172.25.232.151'
        SSH_USER = 'taye'  
        SSH_KEY_PATH = '/var/jenkins_home/.ssh/id_rsa'
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
                    echo "Building Docker image..."
                    image = docker.build("${DOCKER_IMAGE}:${TAG}")
                }
            }
        }

        stage('Snyk Scan') {
            steps {
                script {
                    echo "Scanning for vulnerabilities..."
                    withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                        sh """
                            snyk auth \$SNYK_TOKEN
                            snyk test --docker ${DOCKER_IMAGE}:${TAG} --file=Dockerfile
                        """
                    }
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    echo "Pushing Docker image to DockerHub..."
                    image.push()
                }
            }
        }

        stage('Deploy to Vm') {
            steps {
                script {
                    echo "Deploying to ${env.BRANCH_NAME} environment..."

                
                    sh 'chmod 600 $SSH_KEY_PATH'

                    
                    def composeFile = ''
                    if (env.BRANCH_NAME == 'testing') {
                        composeFile = '/home/tayelolu/pythonapp2/docker-compose.testing.yml'
                    } else if (env.BRANCH_NAME == 'staging') {
                        composeFile = '/home/tayelolu/pytonapp2/docker-compose.staging.yml'
                    } else if (env.BRANCH_NAME == 'main') {
                        composeFile = '/home/tayelolu/pythonapp2/docker-compose.yaml'
                    } else {
                        echo "Branch ${env.BRANCH_NAME} has no deployment config."
                        return
                    }

                    
                    sh """
                        ssh -o StrictHostKeyChecking=yes -i ${SSH_KEY_PATH} ${SSH_USER}@${VM_IP} \\
                        'docker-compose -f ${composeFile} up -d'
                    """
                }
            }
        }
    }
}
