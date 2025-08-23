pipeline {
    options {
        timeout(time: 20, unit: 'MINUTES')  // Timeout for the entire pipeline
        retry(2)  // Retry the entire pipeline twice if it fails
    }
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
                    volumeMounts:
                    - name: kubeconfig
                      mountPath: /root/.kube/
                      readOnly: true
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
                  - name: kubeconfig
                    secret:
                      secretName: minikube-kubeconfig
            '''
        }
    }
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE = 'hussienmohamed/calculator'  // Replace with your DockerHub username
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = credentials('minikube-config')  // We'll create this credential in Jenkins
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
                timeout(time: 5, unit: 'MINUTES') {  // Timeout for deployment
                container('kubectl') {
                    // Copy kubeconfig to the expected location
                    sh """
                        mkdir -p /root/.kube
                        echo "$KUBECONFIG" > /root/.kube/config
                        chmod 600 /root/.kube/config
                        
                        # Verify connection
                        kubectl cluster-info
                        
                        # Deploy the application
                        sed -i 's/\${BUILD_NUMBER}/${BUILD_NUMBER}/g' k8s/deployment.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for deployment
                        kubectl rollout status deployment/calculator-app
                    """
                }
            }
        }
    }
}
