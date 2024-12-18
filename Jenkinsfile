pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout the Python Flask app from GitHub
                git branch: 'main', url: 'https://github.com/vishnu-arava/PythonApp.git'
            }
        }

        stage('SonarQube Analysis') {
          def scannerHome = tool 'SonarScanner';
          withSonarQubeEnv() {
            sh "${scannerHome}/bin/sonar-scanner"
            }
        }

        stage('Build') {
            steps {
                script {
                    // Archive the Python Flask app (e.g., create a zip of the app)
                    sh 'zip -r WeatherApp.zip .'
                    archiveArtifacts artifacts: 'WeatherApp.zip', allowEmptyArchive: true
                }
            }
        }
    }
}
