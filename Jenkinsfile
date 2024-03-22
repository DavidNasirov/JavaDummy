pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                // Add your Jenkins build steps here
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                // Add your Jenkins test steps here
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Add your Jenkins deployment steps here
            }
        }
    }

    post {
        always {
            echo 'Post-build cleanup...'
            // Add any post-build cleanup steps here
        }
    }
}