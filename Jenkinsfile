pipeline {
    agent any
    stages {
        
        stage('Build Started'){
            steps{
                sh "echo Building ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            }
        }
        
        stage('Checking and Installing Hadolint'){
            steps{
                sh '''
                    if ! [ -x "$(command -v hadolint)" ]; then
                        echo 'Installing hadolint' >&2
                        make install
                    fi
                '''
            }
        }
        
        stage('Linting Docker File'){
            steps{
                sh 'make lint'
            }
        }
        
        stage('Build & Push to dockerhub') {
      steps {
        script {
          cd app
          dockerImage = docker.build("nilay16/capstone:${env.GIT_HASH}")
          docker.withRegistry('', docker-id) {
            dockerImage.push()
          }
        }

      }
    }

    stage('Scan Dockerfile to find vulnerabilities') {
      steps {
        aquaMicroscanner(imageName: "nilay16/capstone:${env.GIT_HASH}", notCompliesCmd: 'exit 0', onDisallowed: 'pass', outputFormat: 'html')
      }
    }

    stage('Build Docker Container') {
      steps {
        sh "docker run --name capstone -d -p 80:3000 nilay16/capstone:${env.GIT_HASH}"
      }
    }
  
         stage('Deploying app to AWS EKS') {
              steps{
                  echo 'Deploying to AWS EKS ....'
                  withAWS(credentials: 'capstone', region: 'ap-south-1') {
                      sh "aws eks --region ap-south-1 update-kubeconfig --name capstone"
                      sh "kubectl config use-context arn:aws:eks:ap-south-1:936344068960:cluster/capstone"
                      sh "kubectl apply -f ./clusters/deploy.yaml"
                      sh "kubectl get nodes"
                      sh "kubectl get deployments"
                      sh "kubectl get pod -o wide"
                      sh "kubectl get service/capstone"
                }
            }
        }
    }
}
