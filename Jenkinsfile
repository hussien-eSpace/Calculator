pipeline {
    options {
        timeout(time: 20, unit: 'MINUTES')
        retry(2)
    }
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
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
    image: alpine/k8s:1.24.16
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
        DOCKER_IMAGE = 'hussienmohamed/calculator'
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
                    script {
                        // Update the deployment with the new image
                        sh "kubectl set image deployment/calculator-app calculator=hussienmohamed/calculator:${BUILD_NUMBER} || true"
                        
                        // Apply the manifests
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                        
                        // Wait for deployment
                        sh "kubectl rollout status deployment/calculator-app --timeout=300s"
                    }
                }
            }
        }
    }
}