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
            echo "🧹 Limpiando instalación previa de ArgoCD..."
            echo "==========================================="
            kubectl delete namespace $NAMESPACE --context $CONTEXT || true

            echo "==========================================="
            echo "📦 Creando namespace..."
            echo "==========================================="
            kubectl create namespace $NAMESPACE --context $CONTEXT

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
   
/* 
        stage('Install & Access ArgoCD') {
            steps {
                sh '''
                    # 1. Crear namespace e instalar
                    kubectl create namespace argocd --context kind-argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context kind-argocd || true
                    
                    # 2. Esperar a que el servidor esté listo (importante antes de pedir la pass)
                    echo "Esperando a que ArgoCD Server esté disponible..."
                    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd --context kind-argocd
                         
                    # 4. Port-forward en segundo plano (puerto 9093)
                    # El '&' al final lo corre en background para que Jenkins pueda seguir
                    
                    
                    # Darle un par de segundos para que el túnel se establezca
                    sleep 25
                    echo "ArgoCD disponible en: https://localhost:9093"

                    # 1. Sacar la contraseña (Usuario: admin)
                    echo -n "Contraseña de ArgoCD: " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
                    
                    # 2. Iniciar Port-Forward en 9093
                    # Usamos & para que se ejecute en segundo plano y te devuelva el control de la terminal
                    kubectl port-forward svc/argocd-server -n argocd 9093:443 --address 0.0.0.0 > argocd-pf.log 2>&1 &
                    
                '''
            }
        }
*/
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
