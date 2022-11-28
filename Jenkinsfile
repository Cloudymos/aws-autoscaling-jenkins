pipeline {
    agent any
    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: ['Create/Update', 'Destroy'], description: 'What action will be performed with Terraform? ')
    }
    tools {
       terraform 'Terraform'
    }
    stages {
        stage('Terraform init') {
            steps {
                withAWS(credentials: 'aws-bruno-credencials'){
                    sh "terraform init"
                }
            }
        }
        stage('Terraform Validate') {
            steps {
                withAWS(credentials: 'aws-bruno-credencials'){
                    sh "terraform validate"
                }
            }
        }
        stage('Terraform plan') {
            when {
                expression { params.TERRAFORM_ACTION == 'Create/Update' }
            }            
            steps {
                withAWS(credentials: 'aws-bruno-credencials'){
                    sh "terraform plan"
                }
            }
        }
        stage('Terraform apply') {
            when {
                expression { params.TERRAFORM_ACTION == 'Create/Update' }
            }              
            steps {
                input('Do you want to proceed to changes?')
                withAWS(credentials: 'aws-bruno-credencials'){
                    sh "terraform apply -auto-approve"
                }
            }
        }
        stage('Terraform destroy') {
            when {
                expression { params.TERRAFORM_ACTION == 'Destroy' }
            }              
            steps {
                input('Do you want destroy everything?')
                withAWS(credentials: 'aws-bruno-credencials'){
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
