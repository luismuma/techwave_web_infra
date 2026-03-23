#!/bin/bash
# create-kind.sh
# Crea un cluster Kind y espera a que esté listo

set -euo pipefail

CLUSTER_NAME="${1:-argocd}"

echo "==========================================="
echo "🚀 Creando cluster Kind: $CLUSTER_NAME"
echo "==========================================="

# Crear cluster
kind create cluster --name "$CLUSTER_NAME"

# Función para esperar a que el cluster esté listo
wait_for_cluster() {
  echo "⏳ Esperando a que el API server esté listo..."
  until kubectl version --short >/dev/null 2>&1; do
    sleep 2
  done

  echo "⏳ Esperando a que los nodos estén Ready..."
  kubectl wait --for=condition=Ready nodes --all --timeout=60s
}

wait_for_cluster

echo "✅ Cluster Kind '$CLUSTER_NAME' creado y listo."
echo "Puedes verificar con: kubectl cluster-info --context kind-$CLUSTER_NAME"
