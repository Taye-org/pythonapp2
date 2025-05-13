@Library('jenkins-shared-library') _
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
                    branchTag = (env.BRANCH_NAME == 'main') ? 'latest' : env.BRANCH_NAME
                    env.BRANCH_TAG = branchTag
                    echo "Branch tag is: ${branchTag}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    image = dockerbuild(DOCKER_IMAGE, "${branchTag}-${TAG}")
                }
            }
        }

        stage('Snyk Vulnerability Scan') {
            steps {
                script {
                    snykscan(DOCKER_IMAGE, "${branchTag}-${TAG}")
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    dockerlogin()
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    dockerpush(image, "${branchTag}-${TAG}", branchTag)
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                script {
                    deployvm(env.BRANCH_NAME, branchTag, VM_IP, SSH_USER, SSH_KEY_PATH, DOCKER_IMAGE)
                }
            }
        }
    }
}


       
