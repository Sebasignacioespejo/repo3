pipeline {
    agent any
    
    environment {
        AZURE_CREDENTIALS = credentials('azure-credentials')  // Usamos el ID de las credenciales que creaste
    }
    
    stages {
        stage('Preparar credenciales Azure') {
            steps {
                script {
                    // Cargar las credenciales de Azure desde el archivo JSON o los valores
                    withCredentials([string(credentialsId: 'azure-credentials', variable: 'AZURE_CREDENTIALS')]) {
                        sh """
                            echo ${AZURE_CREDENTIALS} > azure_creds.json
                            export ARM_CLIENT_ID=$(jq -r .clientId azure_creds.json)
                            export ARM_CLIENT_SECRET=$(jq -r .clientSecret azure_creds.json)
                            export ARM_SUBSCRIPTION_ID=$(jq -r .subscriptionId azure_creds.json)
                            export ARM_TENANT_ID=$(jq -r .tenantId azure_creds.json)
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
    }
}
