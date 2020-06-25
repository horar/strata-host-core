def installer_path = ""
pipeline {
    agent { 
        node { 
            label 'master'
            // Location for spyglass contentns to be cloned to. e.g C:/spyglass-repo
            // TODO: Use Jenkins env to better identify drive letter
            customWorkspace "C:/spyglass-repo"
        } 
    }
    stages {
        stage('Build') {
            steps {
                echo "Building installer"
                sh "${env.workspace}/deployment/Strata/deploy_strata_windows.sh"
            }
        }           
        stage('Test') {
            steps {
                script{
                    // Logic to find the most recent build
                    // TODO: refactor deploy_strata_windows.sh to better control & identify build location 
                    def dir_path = sh(encoding: 'UTF-8', script: "ls C:/build -t | head -1", returnStdout: true)
                    dir_path = dir_path.minus("\n")
                    installer_path = sh(encoding: 'UTF-8', script: "find '/C/build/$dir_path' -maxdepth 1 -mindepth 1 -name 'Strata Developer Studio v*.exe' ", returnStdout: true)
                    installer_path = installer_path.substring(0, installer_path.length() - 1);
                    installer_path = sh(encoding: 'UTF-8', script: "cygpath -wa '$installer_path'", returnStdout: true)
                    installer_path = installer_path.substring(0, installer_path.length() - 1);
                }
                echo "Installer Path $installer_path"
                powershell "${env.workspace}/host/test/release-testing/Test-StrataRelease.ps1 '${installer_path}'"              
            }
        }
        // TODO: Clean up stage goes here    
    }
}
