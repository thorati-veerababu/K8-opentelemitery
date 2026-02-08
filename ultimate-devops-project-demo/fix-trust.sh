#!/bin/bash
set -e

CLUSTER_NAME="open-telimetory-cluster"
REGION="ap-south-1"
ACCOUNT_ID="977527527612"
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"

# Get correct OIDC URL from Cluster
OIDC_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text)
# Strip protocol for OIDC Provider ID
OIDC_Provider=$(echo $OIDC_URL | sed 's/https:\/\///')

echo "Updating Trust Policy for $ROLE_NAME"
echo "OIDC Provider: $OIDC_Provider"

# Generate Policy
cat > new-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_Provider}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${OIDC_Provider}:aud": "sts.amazonaws.com",
                    "${OIDC_Provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

# Update Role
aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document file://new-trust-policy.json

echo "✅ Trust Policy Updated."

# Restart Controller to force token refresh
kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
