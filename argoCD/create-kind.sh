#!/bin/bash
# create-kind.sh
# Crea un cluster Kind y espera a que esté listo

set -euo pipefail

CLUSTER_NAME="${1:-argocd}"

echo "==========================================="
echo "🚀 Creando cluster Kind: $CLUSTER_NAME"
echo "==========================================="

# Crear cluster
# kind create cluster --name "$CLUSTER_NAME"
kind create cluster --name "$CLUSTER_NAME" --image kindest/node:v1.29.2 --wait 5m

echo "✅ Cluster Kind '$CLUSTER_NAME' creado y listo."
echo "Puedes verificar con: kubectl cluster-info --context kind-$CLUSTER_NAME"
