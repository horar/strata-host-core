// REPO_NAME & ROOT_BUILD_DIR must be as short as possible
def REPO_NAME = "s"
def ROOT_BUILD_DIR = "b"
def BUILD_NAME = ""
def INSTALLER_PATH = ""
pipeline {
    agent { 
        node { 
            label 'master'
            // TODO: hard drive letter should be loaded from ${env.SystemDrive} but node can't access env
            customWorkspace "C:/${REPO_NAME}"
        } 
    }
    stages {
        stage('Build') {
            steps {
                script{
                    BUILD_NAME = sh(encoding: 'UTF-8', script: "date +%m%d_%H%M%S%SS", returnStdout: true)
                    BUILD_NAME = BUILD_NAME.minus("\n")
                }
                sh "${env.workspace}/deployment/Strata/deploy_strata_windows.sh -r '${env.workspace}/${ROOT_BUILD_DIR}' -d '${BUILD_NAME}'"
            }
        }           
        stage('Test') {
            steps {
                script{
                    INSTALLER_PATH = sh(encoding: 'UTF-8', script: "find '${env.workspace}/${ROOT_BUILD_DIR}/${BUILD_NAME}' -type f  -iname 'Strata*.exe' ", returnStdout: true)
                    INSTALLER_PATH = INSTALLER_PATH.minus("\n")
                }
                echo "Installer Path: $INSTALLER_PATH"
                //powershell "${env.workspace}/host/test/release-testing/Test-StrataRelease.ps1 '${INSTALLER_PATH}'"              
            }
        }
        stage('Deploy'){
            steps{
                sh "python -m venv ${env.workspace}/deployment/OTA/ota-deploy-env"
                sh "source ${env.workspace}/deployment/OTA/ota-deploy-env/Scripts/activate"
                sh "python -m pip install -r ${env.workspace}/deployment/OTA/requirements.txt"
                sh """python '${env.workspace}/deployment/OTA/deploy.py' \
                    --dir '${BUILD_NAME}' \
                    --hcs '${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin/hcs.exe' \
                    --devstudio '${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin/Strata Developer Studio.exe' \
                    --views '${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin' \
                    --qmlcomponents '${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin' \
                    --libs '${ROOT_BUILD_DIR}/${BUILD_NAME}/b/bin'
                    """
                archiveArtifacts artifacts: "${ROOT_BUILD_DIR}/${BUILD_NAME}/Strata*.exe", onlyIfSuccessful: true
            }
        }
    }
}