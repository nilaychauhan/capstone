pipeline {
    agent any
    stages {
        
        stage('Build Started'){
            steps{
                sh "echo Building ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            }
        }
        
        stage('Lint Dockerfile') {
            steps {
                script {
                    docker.image('hadolint/hadolint:latest-debian').inside() {
                        sh 'hadolint ./Dockerfile | tee -a hadolint_lint.txt'
                        sh '''
lintErrors=$(stat --printf="%s"  hadolint_lint.txt)
if [ "$lintErrors" -gt "0" ]; then
echo "Errors have been found, please see below"
cat hadolint_lint.txt
exit 1
else
echo "There are no erros found on Dockerfile!!"
fi
'''
          }
        }

      }
    }
        
        stage('Building Docker Image') {
            steps {
                sh 'bash run_docker.sh'
            }
        }
        
        stage('Pushing Docker Image') {
            steps {
                withDockerRegistry([url: "", credentialsId: "docker-id"]) {
                    sh 'bash upload_docker.sh'
                }
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
