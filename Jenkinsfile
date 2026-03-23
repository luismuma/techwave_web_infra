pipeline {
    agent any

    stages {
        stage('Execute Delete Script') {
            steps {
                // El script ya está aquí gracias al checkout automático de Jenkins
                sh '''
                    chmod +x ./delete-kind.sh
                    ./delete-kind.sh
                '''
            }
        }
    }
    
    post {
        success {
            echo "Kind cluster eliminado correctamente."
        }
        cleanup {
            cleanWs() // Buena práctica: dejar el workspace limpio
        }
    }
}
