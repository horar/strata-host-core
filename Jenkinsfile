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
                dir("deployment/Strata") { 
                //    bat 'bash deploy_strata_windows.sh'
                    sh "deploy_strata_windows.sh"
                    echo "done" 
                }
            }
        }
    }
}
