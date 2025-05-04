pipeline {
    agent any

    environment {
        TF_VAR_resource_group_name = 'rg-gogs'
        TF_VAR_location = 'eastus'
        TF_VAR_vm_admin_username = 'azureuser'
        TF_VAR_gogs_db_name = 'gogsdb'
        TF_VAR_gogs_db_user = 'gogsadmin'
        TF_VAR_gogs_db_password = 'MySuperSecretP@ssword123'
    }

    stages {
        stage('Preparar credenciales Azure') {
            steps {
                withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]) {
                    script {
                        writeFile file: 'azure_creds.json', text: "${AZURE_CREDENTIALS}"
                        sh '''
                            export ARM_CLIENT_ID=$(jq -r '.clientId' azure_creds.json)
                            export ARM_CLIENT_SECRET=$(jq -r '.clientSecret' azure_creds.json)
                            export ARM_SUBSCRIPTION_ID=$(jq -r '.subscriptionId' azure_creds.json)
                            export ARM_TENANT_ID=$(jq -r '.tenantId' azure_creds.json)
                            echo "Credenciales exportadas para Terraform."
                        '''
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
                sh 'ansible-playbook -i inventory.ini playbook.yml'
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
}
