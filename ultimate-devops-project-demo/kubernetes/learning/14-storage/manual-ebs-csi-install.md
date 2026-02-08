# 🔧 Manual EBS CSI Driver Installation (Step-by-Step)

> **Goal**: Install EBS CSI driver on EKS manually to understand each component

---

## 📚 What You'll Learn

1. How Kubernetes connects to AWS (OIDC + IAM Roles)
2. How ServiceAccounts get AWS permissions (IRSA)
3. How CSI drivers work in Kubernetes

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         EKS CLUSTER                              │
│                                                                  │
│  ┌──────────────────┐         ┌──────────────────────────────┐  │
│  │ EBS CSI Driver   │         │     ServiceAccount           │  │
│  │   Controller     │────────►│  ebs-csi-controller-sa       │  │
│  │ (creates volumes)│         │                              │  │
│  └────────┬─────────┘         └──────────────┬───────────────┘  │
│           │                                   │                  │
│           │ uses                              │ annotated with   │
│           ▼                                   ▼                  │
│  ┌──────────────────┐         ┌──────────────────────────────┐  │
│  │   AWS EBS API    │◄────────│      IAM Role ARN            │  │
│  │  (CreateVolume)  │         │  via OIDC Trust Policy       │  │
│  └──────────────────┘         └──────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
                               ┌──────────────────┐
                               │   AWS IAM        │
                               │   OIDC Provider  │
                               └──────────────────┘
```

---

## Step 1: Verify OIDC Provider

**What is OIDC?** It allows Kubernetes ServiceAccounts to assume IAM roles.

```bash
# Get your cluster's OIDC issuer URL
aws eks describe-cluster \
    --name <YOUR_CLUSTER_NAME> \
    --query "cluster.identity.oidc.issuer" \
    --output text
```

Expected output: `https://oidc.eks.ap-south-1.amazonaws.com/id/XXXXXXXXXXXXXXX`

```bash
# Extract just the OIDC ID
OIDC_ID=$(aws eks describe-cluster \
    --name <YOUR_CLUSTER_NAME> \
    --query "cluster.identity.oidc.issuer" \
    --output text | cut -d '/' -f 5)

echo $OIDC_ID
```

```bash
# Check if OIDC provider exists in IAM
aws iam list-open-id-connect-providers | grep $OIDC_ID
```

**If no output**, create it:
```bash
eksctl utils associate-iam-oidc-provider \
    --cluster <YOUR_CLUSTER_NAME> \
    --approve
```

---

## Step 2: Create IAM Policy for EBS

AWS provides a managed policy, but let's understand it:

```bash
# Option A: Use AWS managed policy (recommended)
# Policy ARN: arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

# Option B: View what the policy allows
aws iam get-policy-version \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --version-id v1 \
    --query 'PolicyVersion.Document'
```

The policy allows:
- `ec2:CreateVolume` - Create EBS volumes
- `ec2:DeleteVolume` - Delete EBS volumes  
- `ec2:AttachVolume` - Attach to nodes
- `ec2:DetachVolume` - Detach from nodes
- `ec2:CreateSnapshot` - For backups
- And more...

---

## Step 3: Create IAM Role with Trust Policy

### 3a. Create Trust Policy File

Create file: `ebs-csi-trust-policy.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>:aud": "sts.amazonaws.com",
          "oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
```

**Replace**:
- `<ACCOUNT_ID>` - Your AWS account ID
- `<REGION>` - Your region (e.g., ap-south-1)
- `<OIDC_ID>` - From Step 1

### 3b. Create the IAM Role

```bash
aws iam create-role \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --assume-role-policy-document file://ebs-csi-trust-policy.json
```

### 3c. Attach the Policy

```bash
aws iam attach-role-policy \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

### 3d. Verify

```bash
aws iam get-role --role-name AmazonEKS_EBS_CSI_DriverRole
```

---

## Step 4: Install EBS CSI Driver

### Option A: As EKS Add-on (Recommended)

```bash
# Get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Install the add-on
aws eks create-addon \
    --cluster-name <YOUR_CLUSTER_NAME> \
    --addon-name aws-ebs-csi-driver \
    --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole
```

### Option B: Using Helm (More Control)

```bash
# Add the helm repo
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

# Install
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set controller.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::<ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole
```

---

## Step 5: Verify Installation

```bash
# Check add-on status
aws eks describe-addon \
    --cluster-name <YOUR_CLUSTER_NAME> \
    --addon-name aws-ebs-csi-driver \
    --query 'addon.status'
```

Expected: `"ACTIVE"`

```bash
# Check pods are running
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```

Expected output:
```
NAME                                  READY   STATUS    RESTARTS   AGE
ebs-csi-controller-xxxxxxxxx-xxxxx    6/6     Running   0          1m
ebs-csi-controller-xxxxxxxxx-xxxxx    6/6     Running   0          1m
ebs-csi-node-xxxxx                    3/3     Running   0          1m
ebs-csi-node-xxxxx                    3/3     Running   0          1m
```

```bash
# Check CSI driver is registered
kubectl get csidriver
```

Expected: `ebs.csi.aws.com`

---

## ✅ Success Criteria

| Check | Command | Expected |
|-------|---------|----------|
| Add-on active | `aws eks describe-addon ...` | `"ACTIVE"` |
| Controller pods | `kubectl get pods -n kube-system -l app=ebs-csi-controller` | 2 pods, 6/6 Ready |
| Node pods | `kubectl get pods -n kube-system -l app=ebs-csi-node` | 1 per node, 3/3 Ready |
| CSI driver | `kubectl get csidriver` | `ebs.csi.aws.com` |

---

## 🎯 Next Steps

Once EBS CSI driver is active, proceed to:
1. `kubectl apply -f 01-storageclass.yaml`
2. `kubectl apply -f 02-pvc.yaml`
3. `kubectl apply -f 03-pod-with-pvc.yaml`

---

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Add-on stuck in "CREATING" | Check IAM role trust policy |
| Pods in CrashLoop | Check `kubectl logs` and IAM permissions |
| Volume not attaching | Check node IAM role has EC2 permissions |
