pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_Access_key')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_Secret_Key')
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

        stage('Prepare for Ansible') {
            steps {
                script {
                    def public_ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()

                    writeFile file: 'ansible/inventory.ini', text: """
[web]
${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/jenkins_home/lab1-kp.pem
"""

                    sh """
                        mkdir -p /var/jenkins_home/.ssh
                        ssh-keyscan -H ${public_ip} >> /var/jenkins_home/.ssh/known_hosts
                        chmod 600 /var/jenkins_home/lab1-kp.pem
                    """
                }
            }
        }

        stage('Wait for EC2 Ready') {
            steps {
                echo 'Waiting 150 seconds for instance to be SSH-ready...'
                sh 'sleep 60'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }
}
