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

stage('Install & Access ArgoCD on Kind') {
    steps {
        sh '''
            set -e

            CONTEXT="kind-argocd"
            NAMESPACE="argocd"
            NODE_PORT=30888

            
            echo "==========================================="
            echo "🚀 Instalando ArgoCD (No incluye CRDs)..."
            echo "==========================================="
            kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/namespace-install.yaml
            
            echo "==========================================="
            echo "⏳ Esperando a que ArgoCD Server esté listo..."
            echo "==========================================="
            kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $NAMESPACE --context $CONTEXT

            echo "==========================================="
            echo "🔑 Obteniendo contraseña inicial de admin..."
            echo "==========================================="
            ADMIN_PASS=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret --context $CONTEXT -o jsonpath="{.data.password}" | base64 -d)
            echo "Contraseña inicial de ArgoCD: $ADMIN_PASS"

            echo "==========================================="
            echo "🌐 Configurando NodePort para acceso HTTP..."
            echo "==========================================="
            kubectl patch svc argocd-server -n "$NAMESPACE" --context "$CONTEXT" \
              -p "{\\"spec\\":{\\"type\\":\\"NodePort\\",\\"ports\\":[{\\"port\\":80,\\"targetPort\\":8080,\\"nodePort\\":$NODE_PORT,\\"protocol\\":\\"TCP\\"}]}}"

            echo "ArgoCD HTTP accesible en: http://localhost:$NODE_PORT"
            # 🔧 Opcional: esperar un poco para asegurar que NodePort esté activo
            sleep 10

            echo "==========================================="
            echo "✅ ArgoCD listo para usar en Kind"
            echo "==========================================="
        '''
    }
}
stage('Port-forward ArgoCD') {
    steps {
        sh '''
            CONTEXT="kind-argocd"
            NAMESPACE="argocd"

            echo "🌐 Lanzando port-forward de ArgoCD..."
            kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443 --context $CONTEXT &
            echo "Port-forward activo en https://localhost:8080 (Ctrl+C para detener)"
        '''
    }
}
   
stage('Create ArgoCD Application') {
    steps {
        sh '''
            set -e
            echo "📦 Creando ArgoCD Application..."
            kubectl apply -f argoCD/argo-application.yaml --context kind-argocd
            echo "✅ Application creada"
            kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
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
