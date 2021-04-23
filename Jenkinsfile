// REPO_NAME & ROOT_BUILD_DIR must be as short as possible
def REPO_NAME = "s"
def ROOT_BUILD_DIR = "b"
def BUILD_NAME = UUID.randomUUID().toString()
def INSTALLER_PATH = ""
pipeline {
    agent { 
        node { 
            label 'Strata-OTA-Win-Prod || Strata-OTA-Win-Dev'
            // TODO: hard drive letter should be loaded from ${env.SystemDrive} but node can't access env
            customWorkspace "C:/${REPO_NAME}"
        } 
    }
    stages {
        stage('Clone Internal Repository') {
            steps {
                script {
                    def internalRepoUrl = "https://code.onsemi.com/scm/secswst/strata-host-core-internal.git"
                    def internalRepoName = "strata-host-core-internal"

                    dir("${env.workspace}/${internalRepoName}") {
                        git changelog: false,
                            poll: false,
                            credentialsId: 'BB-access-token',
                            url: "${internalRepoUrl}"
                    }
                }
            }
        }
        stage('Clone Strata Platform Control Views Repository') {
            steps {
                script {
                    def repoUrl = "https://code.onsemi.com/scm/secswst/strata-platform-control-views.git"
                    def repoName = "strata-platform-control-views"

                    dir("${env.workspace}/components/${repoName}") {
                        git changelog: false,
                        poll: false,
                        credentialsId: 'BB-access-token',
                        url: "${repoUrl}"
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh "${env.workspace}/strata-host-core-internal/deployment/Strata/deploy_strata_windows.sh -r '${env.workspace}/${ROOT_BUILD_DIR}' -d '${BUILD_NAME}' --nosigning"
            }
        }
        stage('Test') {
            steps {
                script{
                    INSTALLER_PATH = sh(encoding: 'UTF-8', script: "find '${env.workspace}/${ROOT_BUILD_DIR}/${BUILD_NAME}' -type f  -iname 'Strata*.exe' ", returnStdout: true)
                    INSTALLER_PATH = INSTALLER_PATH.minus("\n")
                }
                echo "Installer Path: $INSTALLER_PATH"
                // Tests are disabled at the moment
                //powershell "${env.workspace}/strata-host-core-internal/test/release-testing/Test-StrataRelease.ps1 '${INSTALLER_PATH}'"
            }
        }
        stage('Deploy') {
            steps{
                sh "python -m venv ${env.workspace}/strata-host-core-internal/deployment/OTA/ota-deploy-env"
                sh "source ${env.workspace}/strata-host-core-internal/deployment/OTA/ota-deploy-env/Scripts/activate"
                sh "python -m pip install -r ${env.workspace}/strata-host-core-internal/deployment/OTA/requirements.txt"
                sh """python '${env.workspace}/strata-host-core-internal/deployment/OTA/main.py' \
                    --dir '${BUILD_NAME}' \
                    view \
                    '${env.workspace}/${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin/views'
                    """
                archiveArtifacts artifacts: "${ROOT_BUILD_DIR}/${BUILD_NAME}/Strata*.exe", onlyIfSuccessful: true
            }
        }
    }
}