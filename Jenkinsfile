pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'my-multibranch-app'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        GIT_BRANCH = "${env.BRANCH_NAME}"
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('📋 Environment Info') {
            steps {
                script {
                    echo "🔍 Pipeline Information:"
                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "Build Number: ${env.BUILD_NUMBER}"
                    echo "Git Commit: ${env.GIT_COMMIT}"
                    
                    // Set deployment environment based on branch
                    if (env.BRANCH_NAME == 'main') {
                        env.DEPLOY_ENVIRONMENT = 'production'
                        env.DEPLOY_PORT = '5000'
                        env.SHOULD_DEPLOY = 'true'
                    } else if (env.BRANCH_NAME.contains('develop')) {
                        env.DEPLOY_ENVIRONMENT = 'staging'
                        env.DEPLOY_PORT = '5001'
                        env.SHOULD_DEPLOY = 'true'
                    } else if (env.BRANCH_NAME.startsWith('feature/')) {
                        env.DEPLOY_ENVIRONMENT = 'feature'
                        env.DEPLOY_PORT = '5002'
                        env.SHOULD_DEPLOY = 'false'
                    } else {
                        env.DEPLOY_ENVIRONMENT = 'development'
                        env.DEPLOY_PORT = '5003'
                        env.SHOULD_DEPLOY = 'false'
                    }
                    
                    echo "Deploy Environment: ${env.DEPLOY_ENVIRONMENT}"
                    echo "Will Deploy: ${env.SHOULD_DEPLOY}"
                }
            }
        }
        
        stage('🔍 Code Checkout') {
            steps {
                echo "📥 Checking out code..."
                checkout scm
            }
        }
        
        stage('🏗️ Build') {
            steps {
                echo "🏗️ Building application..."
                script {
                    sh "chmod +x scripts/build.sh"
                    sh "./scripts/build.sh"
                }
            }
        }
        
        stage('🧪 Test') {
            steps {
                echo "🧪 Running tests..."
                script {
                    sh "chmod +x scripts/test.sh"
                    sh "./scripts/test.sh"
                }
            }
        }
        
        stage('🚀 Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo "🚀 Deploying to ${env.DEPLOY_ENVIRONMENT}..."
                script {
                    sh "chmod +x scripts/deploy.sh"
                    sh "./scripts/deploy.sh"
                }
            }
        }
    }
    
    post {
        always {
            echo "🧹 Cleaning up..."
            sh "docker-compose down --volumes --remove-orphans || true"
        }
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "💥 Pipeline failed!"
        }
    }
}
