pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
    }

    stages {
        stage('Preparar credenciales Azure') {
            steps {
                writeFile file: 'azure_creds.json', text: """
                {
                    "clientId": "${env.ARM_CLIENT_ID}",
                    "clientSecret": "${env.ARM_CLIENT_SECRET}",
                    "subscriptionId": "${env.ARM_SUBSCRIPTION_ID}",
                    "tenantId": "${env.ARM_TENANT_ID}",
                    "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
                    "resourceManagerEndpointUrl": "https://management.azure.com/",
                    "activeDirectoryGraphResourceId": "https://graph.windows.net/",
                    "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
                    "galleryEndpointUrl": "https://gallery.azure.com/",
                    "managementEndpointUrl": "https://management.core.windows.net/"
                }
                """
            }
        }

        stage('Verificar archivo JSON') {
            steps {
                sh 'cat azure_creds.json'
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
                sh '''
                    ansible-playbook -i inventario.ini playbook.yml \
                    --extra-vars "azure_credentials=azure_creds.json"
                '''
            }
        }
    }

    post {
        always {
            sh '''
                if [ -f azure_creds.json ]; then
                    rm azure_creds.json
                    echo "Archivo azure_creds.json eliminado."
                else
                    echo "No se encontró azure_creds.json, nada que eliminar."
                fi
            '''
        }
    }
}
