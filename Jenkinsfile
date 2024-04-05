// def imageName="192.168.44.44:8082/docker_registry/frontend"
// def dockerRegistry="https://192.168.44.44:8082"
// def registryCredentials = "artifactory"
def imageName="crashtein/frontend"
def dockerRegistry=""
def registryCredentials = "dockerhub"
def dockerTag=""
pipeline {
    agent {
        label 'agent'
    }
    environment {
        scannerHome = tool 'SonarQube'
        PIP_BREAK_SYSTEM_PACKAGES = 1
    }
    stages {
        stage('Get code') {
            steps {
		checkout scm
            }
        }
        stage('Unit tests') {
            environment {
                PIP_BREAK_SYSTEM_PACKAGES = 1
            }
            steps {
                sh 'pip install -r requirements.txt'
                sh 'python3 -m pytest --cov=. --cov-report xml:test-results/coverage.xml --junitxml=test-results/pytest-report.xml'
            }
        }
        stage('SonarQube') {
            environment {
                scannerHome = tool 'SonarQube';
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerTag = "RC-${BUILD_ID}"
                    dockerImage = docker.build("$imageName:$dockerTag")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry( "$dockerRegistry", "$registryCredentials" ) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }    
                }
            }
        }
    }
    post {
        // If Maven was able to run the tests, even if some of the test
        // failed, record the test results and archive the jar file.
        always {
            junit testResults: "test-results/*.xml"
            cleanWs()
	}
        success {
            build job: 'app_of_apps', parameters: [ string(name: 'frontendDockerTag', value: "$dockerTag")], wait: false
        }
    }
}
