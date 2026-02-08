#!/bin/bash

# Configuration
SERVICE_ACCOUNT_NAME="veera"
NAMESPACE="opentelemetry"
CLUSTER_NAME="my-cluster" # Just a local name for the config
SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# 1. Create the token (Valid for 24 hours)
echo "Generating token for $SERVICE_ACCOUNT_NAME..."
TOKEN=$(kubectl create token $SERVICE_ACCOUNT_NAME -n $NAMESPACE --duration=24h)

if [ -z "$TOKEN" ]; then
    echo "Error: Could not generate token. Does the ServiceAccount exist?"
    exit 1
fi

# 2. Get the Cluster Certificate Authority
CA_DATA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# 3. Create a customized kubeconfig file
KUBECONFIG_FILE="veera-kubeconfig.yaml"

echo "Creating $KUBECONFIG_FILE..."

cat <<EOF > $KUBECONFIG_FILE
apiVersion: v1
kind: Config
clusters:
- name: $CLUSTER_NAME
  cluster:
    certificate-authority-data: $CA_DATA
    server: $SERVER_URL
contexts:
- name: veera-context
  context:
    cluster: $CLUSTER_NAME
    namespace: $NAMESPACE
    user: $SERVICE_ACCOUNT_NAME
current-context: veera-context
users:
- name: $SERVICE_ACCOUNT_NAME
  user:
    token: $TOKEN
EOF

echo ""
echo "✅ Done! To use this login:"
echo "export KUBECONFIG=$(pwd)/$KUBECONFIG_FILE"
echo "kubectl get pods"
