#!/bin/bash
# ============================================================
# EBS CSI DRIVER INSTALLATION SCRIPT FOR EKS
# ============================================================
#
# 📚 WHAT IS EBS CSI DRIVER?
# --------------------------
# The EBS CSI (Container Storage Interface) Driver allows Kubernetes
# to create, attach, and manage AWS EBS volumes.
#
# Without it: You cannot use EBS storage in Kubernetes!
#
# ============================================================

set -e  # Exit on error

# ============================================================
# VARIABLES - UPDATE THESE!
# ============================================================
CLUSTER_NAME="open-telimetory-cluster"   # 👈 Your EKS cluster name
AWS_REGION="ap-south-1"            # 👈 Your AWS region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "============================================"
echo "🔧 EBS CSI Driver Installation"
echo "============================================"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $AWS_REGION"
echo "Account: $ACCOUNT_ID"
echo "============================================"

# ============================================================
# STEP 1: Check if OIDC provider exists
# ============================================================
echo ""
echo "📋 Step 1: Checking OIDC provider..."

OIDC_ID=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --query "cluster.identity.oidc.issuer" \
    --output text | cut -d '/' -f 5)

echo "OIDC ID: $OIDC_ID"

# Check if OIDC provider exists
if aws iam list-open-id-connect-providers | grep -q $OIDC_ID; then
    echo "✅ OIDC provider exists"
else
    echo "⚠️  Creating OIDC provider..."
    eksctl utils associate-iam-oidc-provider \
        --cluster $CLUSTER_NAME \
        --region $AWS_REGION \
        --approve
    echo "✅ OIDC provider created"
fi

# ============================================================
# STEP 2: Create IAM Role for EBS CSI Driver
# ============================================================
echo ""
echo "📋 Step 2: Creating IAM role..."

# Check if role exists
if aws iam get-role --role-name AmazonEKS_EBS_CSI_DriverRole 2>/dev/null; then
    echo "✅ IAM role already exists"
else
    eksctl create iamserviceaccount \
        --name ebs-csi-controller-sa \
        --namespace kube-system \
        --cluster $CLUSTER_NAME \
        --region $AWS_REGION \
        --role-name AmazonEKS_EBS_CSI_DriverRole \
        --role-only \
        --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
        --approve
    echo "✅ IAM role created"
fi

# ============================================================
# STEP 3: Install EBS CSI Driver Add-on
# ============================================================
echo ""
echo "📋 Step 3: Installing EBS CSI Driver add-on..."

# Get role ARN
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole"
echo "Role ARN: $ROLE_ARN"

# Check if addon exists
if aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver --region $AWS_REGION 2>/dev/null; then
    echo "✅ EBS CSI Driver add-on already installed"
else
    aws eks create-addon \
        --cluster-name $CLUSTER_NAME \
        --addon-name aws-ebs-csi-driver \
        --service-account-role-arn $ROLE_ARN \
        --region $AWS_REGION
    echo "✅ EBS CSI Driver add-on installation initiated"
fi

# ============================================================
# STEP 4: Wait for add-on to be ready
# ============================================================
echo ""
echo "📋 Step 4: Waiting for EBS CSI Driver to be ready..."

for i in {1..30}; do
    STATUS=$(aws eks describe-addon \
        --cluster-name $CLUSTER_NAME \
        --addon-name aws-ebs-csi-driver \
        --region $AWS_REGION \
        --query 'addon.status' \
        --output text)
    
    echo "Status: $STATUS"
    
    if [ "$STATUS" = "ACTIVE" ]; then
        echo "✅ EBS CSI Driver is ACTIVE!"
        break
    fi
    
    sleep 10
done

# ============================================================
# STEP 5: Verify installation
# ============================================================
echo ""
echo "📋 Step 5: Verifying installation..."
echo ""

echo "EBS CSI Controller pods:"
kubectl get pods -n kube-system -l app=ebs-csi-controller

echo ""
echo "EBS CSI Node pods:"
kubectl get pods -n kube-system -l app=ebs-csi-node

echo ""
echo "============================================"
echo "✅ EBS CSI Driver Installation Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Apply StorageClass: kubectl apply -f 01-storageclass.yaml"
echo "2. Create PVC: kubectl apply -f 02-pvc.yaml"
echo "3. Test with pod: kubectl apply -f 03-pod-with-pvc.yaml"
echo ""
