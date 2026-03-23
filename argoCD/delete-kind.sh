#!/bin/bash
set -e

CLUSTER_NAME="argocd"

echo "======================================"
echo "🧹 Eliminando cluster kind"
echo "======================================"

# Comprobar si existe el cluster
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "⚠️ Eliminando cluster '$CLUSTER_NAME'..."
  kind delete cluster --name "$CLUSTER_NAME"
  echo "✅ Cluster eliminado correctamente"
else
  echo "ℹ️ El cluster '$CLUSTER_NAME' no existe"
fi
