#!/bin/bash
# create-kind.sh
# Crea un cluster Kind, expone puertos y habilita HTTP temporalmente para ArgoCD

set -euo pipefail

CLUSTER_NAME="${1:-argocd}"

echo "==========================================="
echo "🚀 Creando cluster Kind: $CLUSTER_NAME con puertos expuestos"
echo "==========================================="

# Configuración de Kind con puerto extra para NodePort
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30888
    hostPort: 30888
    protocol: TCP
EOF

# Crear cluster con config
kind create cluster --name "$CLUSTER_NAME" --image kindest/node:v1.29.2 --config kind-config.yaml --wait 5m

echo "✅ Cluster Kind '$CLUSTER_NAME' creado y listo."
echo "Puedes verificar con: kubectl cluster-info --context kind-$CLUSTER_NAME"

# ------------------------------------------
# Configuración temporal de ArgoCD para HTTP
# ------------------------------------------
echo "🌐 Configurando ArgoCD Server para HTTP (solo testing local)..."

# Esperamos a que ArgoCD esté instalado y corriendo
# Ajusta el namespace si usas otro
NAMESPACE=argocd

# Patch del servicio para exponer HTTP en NodePort
kubectl patch svc argocd-server -n $NAMESPACE -p '{"spec":{"ports":[{"port":80,"targetPort":8080,"protocol":"TCP"}],"type":"NodePort"}}'

# Obtener el NodePort asignado
NODE_PORT=$(kubectl get svc argocd-server -n $NAMESPACE -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')

echo "✅ ArgoCD Server HTTP disponible en: http://localhost:$NODE_PORT"
