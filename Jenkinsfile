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
                    kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io --context kind-argocd || true
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
            set -e

            CONTEXT="kind-argocd"
            NAMESPACE="argocd"

            # 1️⃣ Crear namespace
            kubectl create namespace $NAMESPACE --context $CONTEXT || true

            # 2️⃣ Instalar CRDs
            echo "Instalando CRDs de ArgoCD..."
            kubectl create -k https://github.com/argoproj/argo-cd/manifests/crds?ref=stable --context $CONTEXT || true

            # 3️⃣ Instalar ArgoCD
            echo "Instalando ArgoCD..."
            kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context $CONTEXT

            # 4️⃣ Reiniciar ApplicationSet Controller para evitar errores de sincronización
            kubectl rollout restart deployment argocd-applicationset-controller -n $NAMESPACE --context $CONTEXT || true

            # 5️⃣ Esperar a que el server esté listo
            echo "Esperando a que ArgoCD Server esté disponible..."
            kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $NAMESPACE --context $CONTEXT

            # 6️⃣ Obtener contraseña admin
            echo -n "Contraseña inicial de ArgoCD: "
            kubectl -n $NAMESPACE get secret argocd-initial-admin-secret --context $CONTEXT -o jsonpath="{.data.password}" | base64 -d
            echo

            # 7️⃣ Cambiar Service a NodePort (para HTTP)
            echo "Exponiendo ArgoCD Server vía NodePort..."
            kubectl patch svc argocd-server -n $NAMESPACE --context $CONTEXT \
              -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":8080,"protocol":"TCP"}]}}'

            # 8️⃣ Obtener NodePort asignado
            NODE_PORT=$(kubectl get svc argocd-server -n $NAMESPACE --context $CONTEXT -o jsonpath='{.spec.ports[0].nodePort}')
            echo "ArgoCD HTTP accesible en: http://localhost:$NODE_PORT"

            # 🔧 Opcional: esperar unos segundos para asegurar que el service está listo
            sleep 10
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
