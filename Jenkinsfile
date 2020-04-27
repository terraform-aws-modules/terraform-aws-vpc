pipeline {
    agent { node { label 'master' } }

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
    }

    options {
      ansiColor('xterm')
    }

    stages {
        stage('Install some packages') {
            steps {
                sh label: 'Install TfLint', returnStatus: true, script: '''
                  if ! [ -x "$(command -v tflint)" ]; then
                      wget -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v0.15.3/tflint_linux_amd64.zip && sudo unzip /tmp/tflint.zip -d /usr/local/bin
                  fi
                '''
                sh label: 'Install Terraform', returnStatus: true, script: '''
                  if ! [ -x "$(command -v terraform)" ]; then
                      wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip && sudo unzip /tmp/terraform.zip -d /usr/local/bin
                  fi
                '''
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'make tf-init'
            }
        }
        stage('Terraform Validate') {
            steps {
                sh 'make tf-validate'
            }
        }
        stage('Terraform Formatted') {
            steps {
                sh 'make tf-fmt'
            }
        }
        stage('Terraform Lint') {
            steps {
                sh 'make tf-lint'
            }
        }
        stage('Run terratest') {
            steps {
                sh 'make test'
                sh 'make clean'
            }
        }
    }
    post {
        always {
            sh 'sudo chmod -R a+rw .'
            cleanWs()
        }
    }
}
