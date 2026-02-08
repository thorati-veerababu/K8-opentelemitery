#!/bin/bash
set -e

# Configuration
CLUSTER_NAME="open-telimetory-cluster"
REGION="ap-south-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"

echo "Using Account ID: $ACCOUNT_ID"
echo "Cluster: $CLUSTER_NAME ($REGION)"

# 1. Download IAM Policy
echo "1. Downloading IAM Policy..."
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

# 2. Create IAM Policy
echo "2. Creating IAM Policy (if not exists)..."
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)
if [ -z "$POLICY_ARN" ]; then
    POLICY_ARN=$(aws iam create-policy \
        --policy-name $POLICY_NAME \
        --policy-document file://iam_policy.json \
        --query 'Policy.Arn' --output text)
    echo "   Created Policy: $POLICY_ARN"
else
    echo "   Policy already exists: $POLICY_ARN"
fi

# 3. Create IAM Role with OIDC Trust
echo "3. Creating IAM Role for Service Account..."
OIDC_Provider=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text | sed 's/https:\/\///')
echo "   OIDC Provider: $OIDC_Provider"

cat > trust-policy.json <<EOF
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

if ! aws iam get-role --role-name $ROLE_NAME >/dev/null 2>&1; then
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json
    echo "   Created Role: $ROLE_NAME"
    
    aws iam attach-role-policy \
        --policy-arn $POLICY_ARN \
        --role-name $ROLE_NAME
    echo "   Attached Policy to Role"
else
    echo "   Role $ROLE_NAME already exists"
fi

# 4. Create Service Account
echo "4. Creating Kubernetes Service Account..."
cat > aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}
EOF

kubectl apply -f aws-load-balancer-controller-service-account.yaml

# 5. Install Helm Chart
echo "5. Installing AWS Load Balancer Controller via Helm..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

echo "✅ Deployment initiated. Check status with: kubectl get deployment -n kube-system aws-load-balancer-controller"

# Cleanup
rm iam_policy.json trust-policy.json aws-load-balancer-controller-service-account.yaml
