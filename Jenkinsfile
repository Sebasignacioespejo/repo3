pipeline {
  agent any

  environment {
    AZURE_CREDENTIALS = credentials('azure-sp-json')
  }

  stages {
    stage('Preparar credenciales Azure') {
      steps {
        sh '''
          echo "$AZURE_CREDENTIALS" > azure_creds.json
          export ARM_CLIENT_ID=$(jq -r .clientId azure_creds.json)
          export ARM_CLIENT_SECRET=$(jq -r .clientSecret azure_creds.json)
          export ARM_SUBSCRIPTION_ID=$(jq -r .subscriptionId azure_creds.json)
          export ARM_TENANT_ID=$(jq -r .tenantId azure_creds.json)

          echo "Credenciales exportadas para Terraform."
        '''
      }
    }

    stage('Terraform Init y Apply') {
      steps {
        sh '''
          export ARM_CLIENT_ID=$(jq -r .clientId azure_creds.json)
          export ARM_CLIENT_SECRET=$(jq -r .clientSecret azure_creds.json)
          export ARM_SUBSCRIPTION_ID=$(jq -r .subscriptionId azure_creds.json)
          export ARM_TENANT_ID=$(jq -r .tenantId azure_creds.json)

          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Provisionar con Ansible') {
      steps {
        sh '''
          # Suponiendo que ya generaste un inventory.ini con la IP de la VM
          ansible-playbook -i inventory.ini setup-gogs.yml
        '''
      }
    }
  }

  post {
    always {
      sh 'rm -f azure_creds.json'
    }
  }
}
