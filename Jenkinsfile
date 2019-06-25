// `git config --system core.longpaths true` should be set on system level
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Building installer"
                cd deployment/Strata
                sh ./deploy_strata_windows.sh
            }
        }
    }
}
