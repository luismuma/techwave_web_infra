pipeline {
    agent any

    stages {
        stage('Execute Delete Script') {
            steps {
                // El script ya está aquí gracias al checkout automático de Jenkins
                sh '''
                    pwd
                    chmod +x ./argoCD/delete-kind.sh
                    ./argoCD/delete-kind.sh
                '''
            }
        }
        stage('Execute Create cluster Kind') {
            steps {
                sh '''
                    chmod +x ./argoCD/create-kind.sh
                    ./argoCD/create-kind.sh
                    sleep 50
                '''
            }
        }
        stage('Install & Access ArgoCD') {
            steps {
                sh '''
                    # 1. Crear namespace e instalar
                    kubectl create namespace argocd --context kind-argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context kind-argocd
                    
                    # 2. Esperar a que el servidor esté listo (importante antes de pedir la pass)
                    echo "Esperando a que ArgoCD Server esté disponible..."
                    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd --context kind-argocd
                    
                    # 3. Extraer y mostrar la contraseña
                    echo "===================================================="
                    echo "USUARIO: admin"
                    echo -n "CONTRASEÑA: "
                    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context kind-argocd | base64 -d
                    echo -e "\n===================================================="
        
                    # 4. Port-forward en segundo plano (puerto 9093)
                    # El '&' al final lo corre en background para que Jenkins pueda seguir
                    echo "Iniciando Port-Forward en el puerto 9093..."
                    kubectl port-forward svc/argocd-server -n argocd --context kind-argocd 9093:443 --address 0.0.0.0 > pf.log 2>&1 &
                    
                    # Darle un par de segundos para que el túnel se establezca
                    sleep 5
                    echo "ArgoCD disponible en: https://localhost:9093"
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
