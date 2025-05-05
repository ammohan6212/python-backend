pipeline {
    agent any
   

    stages {
        // stage('Clear Workspace') {
        //     steps {
        //         cleanWs()
        //     }
        // }

        stage("Clone the Repository") {
            agent any
            steps {
                script {
                    // Clone the dev branch
                    git branch: 'dev',url: "https://github.com/ammohan6212/front-end.git"
                    // git branch: 'dev',credentialsId: 'github-token',url: "https://github.com/ammohan6212/front-end.git"

                    // Fetch all tags
                    sh 'git fetch --tags'

                    // Get the latest tag correctly
                    def VERSION = sh(
                        script: "git describe --tags \$(git rev-list --tags --max-count=1)",
                        returnStdout: true
                    ).trim()
                    
                    // Make version available as environment variable
                    env.VERSION = VERSION
                    
                    echo "VERSION=${env.VERSION}"
                }
            }
        }

        stage("install the dependencies"){
            agent { label 'security-agent' }
            steps{
                sh 'pip install -r requirements.txt'
            }
        }
        // stage("Linting the Code") {
        //     agent { label 'security-agent' }
        //     steps {
        //         sh '''
        //         flake8 app.py
        //         '''
        //     }
        // }

        // stage("check the dependecy scanning using pip-audit and safety"){
        //     agent { label 'security-agent' }
        //     steps{
        //         sh'''
        //         pip install pip-audit
        //         pip-audit
        //         // pip install safety
        //         // pip freeze > requirements.txt
        //         // safety check -r requirements.txt
        //         snyk test --file=requirements.txt --json > snyk-deps-report.json
        //         trivy fs . --format json --output trivy-fs-report.json
        //        '''
        //     }

        // }

        // stage("Run Unit Tests & Coverage") {
        //     agent { label 'security-agent' }
        //     steps {
        //         sh '''
        //         pip install pytest coverage
        //         coverage run -m pytest
        //         coverage report
        //         coverage xml
        //         '''
        //     }
        // }
        

        

        stage("sonar-scanner stage"){
            agent { label 'security-agent' }
            steps{
                script{
                    
                    sh """
                    
                    ls -la
                    /opt/sonar-scanner/bin/sonar-scanner"""
                }
            }

        }
        //  stage("SonarQube Quality Gate") {
        //     steps {
        //         script {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
        stage("Docker Build Stage") {
            agent { label 'security-agent' }
            steps {
                script {
                    echo "VERSION=${env.VERSION}"
                    sh "docker build -t flask ."
                }
            }
        }
        stage("perform the image scanning with snyk"){
            agent { label 'security-agent' }
            steps{
                sh '''
                docker images 
                snyk auth 9d262b22-1f2c-4069-adb9-696793789926
                snyk test --docker flask:latest --file=Dockerfile --exclude-base-image-vulns
                trivy image flask:latest > trivyimage.txt

                cat trivyimage.txt
                '''
            }
        }
        // stage("perform IAC test with synk"){
        //     agent { label 'security-agent' }
        //     steps{
        //         sh '''
        //         snyk iac test terraform/main.tf --json > snyk-iac-report.json
        //         trivy config ./terraform/ --format json --output trivy-iac-report.json
        //     '''
        //     }
        // }
        stage("secretes detection using the trivy"){
            agent { label 'security-agent' }
            steps{
                sh '''
                trivy fs . --scanners secret --format json --output trivy-secrets.json
                cat trivy-secrets.json
            '''
            }
        }
        stage('Approval') {
            steps {
                // Pausing the pipeline and requesting user input to proceed
                input message: 'Do you approve to proceed to the next stage?', ok: 'Yes, proceed'
            }
        }
        stage("tagging docker container") {
            agent { label 'security-agent' }
            steps {
                sh '''
                docker tag flask:latest mohan14242/flask:latest
                '''
            }
            
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com',"docker_credentials") {  // here we need to install the docker pipeline plugin to this
                        docker.image("mohan14242/flask:latest").push()
                    }
                }
            }
    }   }





//         stage("Deploying into K8s Cluster") {
//             agent { label 'kube-agent'}
//             steps {
//                 script {
//                     withKubeConfig(
//                         credentialsId: 'k8_token',  // Jenkins credentials ID where you stored kubeconfig or token
//                         clusterName: 'my-gke-cluster',  // Optional
//                         namespace: 'dev',  // Your namespace
//                         serverUrl: 'https://35.220.240.181:443',  // ✅ Correct syntax with quotes and https
//                         restrictKubeConfigAccess: false
//                     ) {
//                         sh """
//                         kubectl get nodes
//                         """
//                     }
//                 }
//             }
//         }
        post {
    always {
        script {
            slackSend (
                channel: '#ci-pipeline-status',
                color: '#CCCCCC',
                message: "🔔 Pipeline *#${env.BUILD_NUMBER}* finished. Result: *${currentBuild.currentResult}*"
            )
        }
    }

    success {
        script {
            slackSend (
                channel: '#ci-pipeline-status',
                color: 'good',
                message: "✅ Pipeline *#${env.BUILD_NUMBER}* succeeded for version *${env.VERSION}* on branch *${env.BRANCH_NAME}*"
            )
        }
    }

    failure {
        script {
            slackSend (
                channel: '#ci-pipeline-status',
                color: 'danger',
                message: "❌ Pipeline *#${env.BUILD_NUMBER}* failed on branch *${env.BRANCH_NAME}*. Check Jenkins for logs."
            )
        }
    }

    unstable {
        script {
            slackSend (
                channel: '#ci-pipeline-status',
                color: 'warning',
                message: "⚠️ Pipeline *#${env.BUILD_NUMBER}* is unstable. Review the test/report stages."
            )
        }
    }
}



   }


 
