#!/bin/bash
# create-kind.sh
# Crea un cluster Kind y espera a que esté listo

set -euo pipefail

CLUSTER_NAME="${1:-argocd}"

echo "==========================================="
echo "🚀 Creando cluster Kind: $CLUSTER_NAME con puertos expuestos"
echo "==========================================="

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
echo "ArgoCD NodePort 443 mapeado al host en: https://localhost:30888"
echo "Puedes verificar con: kubectl cluster-info --context kind-$CLUSTER_NAME"
