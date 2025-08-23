pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: maven
                    image: maven:3.8.4-openjdk-11
                    command:
                    - sleep
                    args:
                    - infinity
                  - name: docker
                    image: docker:19.03
                    command:
                    - sleep
                    args:
                    - infinity
                    volumeMounts:
                    - name: docker-sock
                      mountPath: /var/run/docker.sock
                  - name: kubectl
                    image: bitnami/kubectl:latest
                    command:
                    - sleep
                    args:
                    - infinity
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
            '''
        }
    }
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE = 'hussienmohamed/calculator'  // Replace with your DockerHub username
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                container('docker') {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
            post {
                always {
                    container('docker') {
                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Replace the BUILD_NUMBER placeholder in deployment.yaml
                    sh """
                        sed -i 's/\${BUILD_NUMBER}/${BUILD_NUMBER}/g' k8s/deployment.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }
    }
}
