def installer_path = ""
pipeline {
    agent { 
        node { 
            label 'master'
            // Location for spyglass contentns to be cloned to. e.g C:/spyglass-repo
            customWorkspace "C:/spyglass-repo"
        } 
    }
    stages {
        stage('Build') {
            steps {
                echo "Building installer"
                echo "${env.workspace}/deployment/Strata/deploy_strata_windows.sh"
                sh "${env.workspace}/deployment/Strata/deploy_strata_windows.sh"
            }
        }           
        stage('Test') {
            steps {
                script{
                    def dir_path2 = sh(encoding: 'UTF-8', script: "ls C:/build -t | head -1", returnStdout: true)
                    def dir_path = dir_path2.minus("\n")
                    installer_path = sh(encoding: 'UTF-8', script: "find '/C/build/$dir_path' -maxdepth 1 -mindepth 1 -name 'Strata Developer Studio v*.exe' ", returnStdout: true)
                    installer_path = installer_path.substring(0, installer_path.length() - 1);
                    installer_path = sh(encoding: 'UTF-8', script: "cygpath -wa '$installer_path'", returnStdout: true)
                    installer_path = installer_path.substring(0, installer_path.length() - 1);
                }
                echo "Installer Path $installer_path"
                powershell "${env.workspace}/host/test/release-testing/Test-StrataRelease.ps1 '${installer_path}'"              
            }
        }    
    }
}
