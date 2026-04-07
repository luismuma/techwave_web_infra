#!/bin/bash
# deploy-argocd-kind.sh
# Script completo para Kind + ArgoCD accesible por HTTP

set -euo pipefail

CLUSTER_NAME="${1:-argocd}"
NAMESPACE="argocd"

echo "==========================================="
echo "🚀 Creando cluster Kind: $CLUSTER_NAME con puerto expuesto"
echo "==========================================="

# Crear configuración Kind con puerto mapeado
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

# Crear cluster
kind create cluster --name "$CLUSTER_NAME" --image kindest/node:v1.29.2 --config kind-config.yaml --wait 5m

echo "✅ Cluster Kind '$CLUSTER_NAME' creado y listo."
kubectl cluster-info --context kind-$CLUSTER_NAME

# ------------------------------------------
# Instalar CRDs de ArgoCD
# ------------------------------------------
echo "📦 Instalando CRDs de ArgoCD..."
kubectl create namespace "$NAMESPACE" --context kind-$CLUSTER_NAME || true
kubectl create -k https://github.com/argoproj/argo-cd/manifests/crds?ref=stable || true

