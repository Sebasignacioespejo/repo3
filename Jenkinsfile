pipeline {
    agent any
    
    environment {
        AZURE_CREDENTIALS = credentials('jenkins-azure') // ID de la credencial de Azure (tipo "secreto en texto")
    }

    stages {
        stage('Preparar credenciales Azure') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'jenkins-azure', variable: 'AZURE_CREDENTIALS')]) {
                        sh """
                            echo "${AZURE_CREDENTIALS}" > azure_creds.json
                            export ARM_CLIENT_ID=\$(jq -r .clientId azure_creds.json)
                            export ARM_CLIENT_SECRET=\$(jq -r .clientSecret azure_creds.json)
                            export ARM_SUBSCRIPTION_ID=\$(jq -r .subscriptionId azure_creds.json)
                            export ARM_TENANT_ID=\$(jq -r .tenantId azure_creds.json)
                            echo Credenciales exportadas para Terraform.
                        """
                    }
                }
            }
        }

        stage('Terraform Init y Apply') {
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Provisionar con Ansible') {
            steps {
                sh 'ansible-playbook -i hosts provisionar_gogs.yml'
            }
        }
    }

    post {
        always {
            sh 'rm -f azure_creds.json'
        }
    }
}
