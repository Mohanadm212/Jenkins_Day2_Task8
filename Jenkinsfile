pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_Access_key')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_Secret_Key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Mohanadm212/Jenkins_Day2_Task8.git' 
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh """
                    terraform apply -auto-approve \
                      -var 'aws_access_key=${AWS_ACCESS_KEY_ID}' \
                      -var 'aws_secret_key=${AWS_SECRET_ACCESS_KEY}'
                    """
            }
        }

        stage('Wait for EC2 Ready') {
            steps {
                echo 'Waiting 60 seconds for instance to be SSH-ready...'
                sh 'sleep 60'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }

    post {
        always {
            echo 'Destroying infrastructure...'
            sh """
                terraform destroy -auto-approve \
                  -var 'aws_access_key=${AWS_ACCESS_KEY_ID}' \
                  -var 'aws_secret_key=${AWS_SECRET_ACCESS_KEY}'
                """
        }
    }
}
