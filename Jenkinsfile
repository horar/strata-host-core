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
        stage('Build') {
            steps {
                sh "${env.workspace}/internal/deployment/Strata/deploy_strata_windows.sh -r '${env.workspace}/${ROOT_BUILD_DIR}' -d '${BUILD_NAME}' --nosigning"
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
                //powershell "${env.workspace}/internal/test/release-testing/Test-StrataRelease.ps1 '${INSTALLER_PATH}'"              
            }
        }
        stage('Deploy'){
            steps{
                sh "python -m venv ${env.workspace}/internal/deployment/OTA/ota-deploy-env"
                sh "source ${env.workspace}/internal/deployment/OTA/ota-deploy-env/Scripts/activate"
                sh "python -m pip install -r ${env.workspace}/internal/deployment/OTA/requirements.txt"
                sh """python '${env.workspace}/internal/deployment/OTA/main.py' \
                    --dir '${BUILD_NAME}' \
                    view \
                    '${env.workspace}/${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin/views'
                    """
                archiveArtifacts artifacts: "${ROOT_BUILD_DIR}/${BUILD_NAME}/Strata*.exe", onlyIfSuccessful: true
            }
        }
    }
}