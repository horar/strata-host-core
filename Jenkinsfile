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
                sh "${env.workspace}/deployment/Strata/deploy_strata_windows.sh -r '${env.workspace}/${ROOT_BUILD_DIR}' -d '${BUILD_NAME}' -c"
            }
        }           
        stage('Test') {
            steps {
                script{
                    INSTALLER_PATH = sh(encoding: 'UTF-8', script: "find '${env.workspace}/${ROOT_BUILD_DIR}/${BUILD_NAME}' -type f  -iname 'Strata*.exe' ", returnStdout: true)
                    INSTALLER_PATH = INSTALLER_PATH.minus("\n")
                }
                echo "Installer Path: $INSTALLER_PATH"
                powershell "${env.workspace}/host/test/release-testing/Test-StrataRelease.ps1 '${INSTALLER_PATH}'"              
            }
        }
        stage('Deploy'){
            steps{
                // TODO: To submit host binaries and control views to S3 & OTA API
                // https://ons-sec.atlassian.net/browse/CS-808
                archiveArtifacts artifacts: "${ROOT_BUILD_DIR}/${BUILD_NAME}/Strata*.exe", onlyIfSuccessful: true
            }
        }
    }
}