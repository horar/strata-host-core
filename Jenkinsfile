pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Building installer"
                # `git config --system core.longpaths true` should be set in the system
                sh deployment/Strata/deploy_strata_windows.sh
            }
        }
    }
}
