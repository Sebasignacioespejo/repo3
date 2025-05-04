pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('jenkins-azure')
    }

    stages {
        stage('Preparar credenciales Azure') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'jenkins-azure', variable: 'AZURE_CREDENTIALS')]) {
                        writeFile file: 'azure_creds.json', text: AZURE_CREDENTIALS
                        def json = readJSON file: 'azure_creds.json'

                        env.ARM_CLIENT_ID = json.clientId
                        env.ARM_CLIENT_SECRET = json.clientSecret
                        env.ARM_SUBSCRIPTION_ID = json.subscriptionId
                        env.ARM_TENANT_ID = json.tenantId

                        echo "Credenciales de Azure cargadas correctamente"
                    }
                }
            }
        }

        stage('Terraform Init y Apply') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Provisionar con Ansible') {
            steps {
                sh 'ansible-playbook -i hosts playbook.yml'
            }
        }
    }

    post {
        always {
            node {
                sh 'rm -f azure_creds.json'
            }
        }
    }
}
