#!/bin/bash
set -e

CLUSTER_NAME="open-telimetory-cluster"
REGION="ap-south-1"
OIDC_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text)
OIDC_HOST=$(echo $OIDC_URL | sed 's/https:\/\///' | cut -d/ -f1)

echo "OIDC URL: $OIDC_URL"
echo "OIDC HOST: $OIDC_HOST"

# Fetch Thumbprint using openssl
# Port 443
THUMBPRINT=$(echo | openssl s_client -servername $OIDC_HOST -showcerts -connect $OIDC_HOST:443 2>/dev/null | openssl x509 -fingerprint -noout -sha1 | cut -d= -f2 | tr -d :)

echo "Thumbprint: $THUMBPRINT"

if [ -z "$THUMBPRINT" ]; then
    echo "Failed to retrieve thumbprint"
    exit 1
fi

aws iam create-open-id-connect-provider \
    --url $OIDC_URL \
    --thumbprint-list $THUMBPRINT \
    --client-id-list sts.amazonaws.com

echo "Created OIDC Provider"
