pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_Access_key')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_Secret_Key')
    }

    parameters {
        string(name: 'ACTION', defaultValue: 'Apply', description: 'Terraform Action')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Mohanadm212/Jenkins_Day2_Task8.git' 
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

        stage('Ansible Playbook') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                sshagent(['aws-ssh']) {
                    script {
                        def public_ip = sh(
                            script: 'terraform -chdir=terraform output -raw public_ip',
                            returnStdout: true
                        ).trim()

                        writeFile file: 'ansible/inventory.ini', text: """
[ec2]
${public_ip} ansible_user=ubuntu
"""

                        dir('ansible') {
                            sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml'
                        }
                    }
                }
            }
        }
    } 
}     
