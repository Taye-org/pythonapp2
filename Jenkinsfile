def image = null
def branchTag = ''

pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'taye97/pythonapp2'
        TAG = "${BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
        VM_IP = '172.25.232.151'
        SSH_USER = 'tayelolu'  
        SSH_KEY_PATH = '/var/jenkins_home/.ssh/id_rsa'
        BRANCH_TAG = ''
    }

    stages {

        stage('Branch Name') {
            steps {
                echo "This is branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Set Tag') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'testing') {
                        branchTag = 'testing'
                    } else if (env.BRANCH_NAME == 'staging') {
                        branchTag = 'staging'
                    } else if (env.BRANCH_NAME == 'main') {
                        branchTag = 'latest'
                    } else {
                        branchTag = "unknown-${env.BRANCH_NAME}"
                    }

                    env.BRANCH_TAG = branchTag
                    echo "Branch tag is: ${branchTag}"
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    image = docker.build("${DOCKER_IMAGE}:${branchTag}-${TAG}")
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
                            snyk test --docker ${DOCKER_IMAGE}:${branchTag}-${TAG} --file=Dockerfile --severity-threshold=high || true
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
                    image.push("${branchTag}-${TAG}")
                    image.push(branchTag)  // Also push plain tag like :testing, :staging
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
                        composeFile = '/home/tayelolu/pythonapp2/docker-compose.staging.yml'
                    } else if (env.BRANCH_NAME == 'main') { 
                        composeFile = '/home/tayelolu/pythonapp2/docker-compose.yaml'
                    } else {
                        echo "Branch ${env.BRANCH_NAME} has no deployment config."
                        return
                    }

                    sh """
                        ssh -o StrictHostKeyChecking=yes -i ${SSH_KEY_PATH} ${SSH_USER}@${VM_IP} '
                            cd /home/tayelolu/pythonapp2 &&
                            git fetch origin &&
                            git checkout ${env.BRANCH_NAME} &&
                            git pull origin ${env.BRANCH_NAME} &&
                            docker pull ${DOCKER_IMAGE}:\$BRANCH_TAG &&
                            docker-compose -f ${composeFile} up -d
                        '
                    """
                }
            }
        }
    }
}
    

        
                    
               
                    
