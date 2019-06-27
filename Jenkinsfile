// `git config --system core.longpaths true` should be set on system level
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Building installer"
                script {
                    env.workspace= pwd()
                    echo env.workspace
                }
                // change dir to deployment/Strata (required by installer) 
                dir("deployment/Strata") { 
                    sh "deploy_strata_windows.sh"
                    echo "done" 
                }
            }
        }
    }
}
