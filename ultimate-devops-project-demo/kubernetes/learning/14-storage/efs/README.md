# 📁 EFS Storage Configuration for EKS

## 🎯 What is EFS?

**EFS (Elastic File System)** is AWS's managed NFS service.
Unlike EBS (block storage), EFS is **shared file storage**.

```
┌─────────────────────────────────────────────────────────────────┐
│                         EFS vs EBS                               │
├────────────────────────────┬────────────────────────────────────┤
│          EBS               │              EFS                    │
├────────────────────────────┼────────────────────────────────────┤
│  ┌──────┐                  │        ┌──────────────┐            │
│  │ Pod  │◄──── Volume      │        │     EFS      │            │
│  └──────┘     (attached)   │        │  (Shared)    │            │
│                            │        └──────┬───────┘            │
│  Only ONE pod can write    │               │                    │
│  (ReadWriteOnce - RWO)     │    ┌──────────┼──────────┐        │
│                            │    │          │          │        │
│                            │ ┌──▼──┐   ┌──▼──┐   ┌──▼──┐      │
│                            │ │Pod 1│   │Pod 2│   │Pod 3│      │
│                            │ └─────┘   └─────┘   └─────┘      │
│                            │                                    │
│                            │ ALL pods can read/write!          │
│                            │ (ReadWriteMany - RWX)              │
└────────────────────────────┴────────────────────────────────────┘
```

---

## 📋 Prerequisites

1. ✅ EKS Cluster running
2. ✅ EFS CSI Driver installed (check: `kubectl get csidriver | grep efs`)
3. ⬜ EFS File System created in AWS
4. ⬜ Mount Targets created in each subnet
5. ⬜ Security Group allows NFS (port 2049)

---

## 🚀 Setup Commands

### Step 1: Get Cluster VPC Info

```bash
# Set cluster name
CLUSTER_NAME="open-telimetory-cluster"
REGION="ap-south-1"

# Get VPC ID
VPC_ID=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)
echo "VPC ID: $VPC_ID"

# Get CIDR block
CIDR_BLOCK=$(aws ec2 describe-vpcs \
    --vpc-ids $VPC_ID \
    --query "Vpcs[0].CidrBlock" \
    --output text)
echo "CIDR: $CIDR_BLOCK"
```

### Step 2: Create Security Group for EFS

```bash
# Create security group
SG_ID=$(aws ec2 create-security-group \
    --group-name EFS-SG-EKS \
    --description "Allow NFS traffic for EFS" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)
echo "Security Group ID: $SG_ID"

# Allow NFS (port 2049) from VPC CIDR
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 2049 \
    --cidr $CIDR_BLOCK
```

### Step 3: Create EFS File System

```bash
# Create EFS
EFS_ID=$(aws efs create-file-system \
    --performance-mode generalPurpose \
    --throughput-mode bursting \
    --encrypted \
    --tags Key=Name,Value=eks-efs-storage \
    --region $REGION \
    --query 'FileSystemId' \
    --output text)
echo "EFS ID: $EFS_ID"

# Wait for EFS to be available
echo "Waiting for EFS to be available..."
aws efs describe-file-systems \
    --file-system-id $EFS_ID \
    --query 'FileSystems[0].LifeCycleState'
```

### Step 4: Create Mount Targets

```bash
# Get private subnet IDs (you need at least one per AZ)
SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' \
    --output text)

# Create mount target for each subnet
for SUBNET in $SUBNET_IDS; do
    echo "Creating mount target in subnet: $SUBNET"
    aws efs create-mount-target \
        --file-system-id $EFS_ID \
        --subnet-id $SUBNET \
        --security-groups $SG_ID \
        --region $REGION
done
```

### Step 5: Verify Mount Targets

```bash
# Wait 1-2 minutes, then check
aws efs describe-mount-targets \
    --file-system-id $EFS_ID \
    --query 'MountTargets[*].{SubnetId:SubnetId,State:LifeCycleState}'
```

---

## 📝 Files to Apply

After EFS is created:

1. `01-efs-storageclass.yaml` - StorageClass for EFS
2. `02-efs-pvc.yaml` - PVC requesting EFS storage
3. `03-efs-pods.yaml` - Multiple pods sharing storage

---

## ✅ Success Criteria

| Check | Expected Result |
|-------|-----------------|
| EFS created | `aws efs describe-file-systems` shows your EFS |
| Mount targets | At least 1 per AZ, state = `available` |
| StorageClass | `kubectl get sc` shows efs-sc |
| PVC bound | `kubectl get pvc` shows `Bound` status |
| Pods can share | Multiple pods read/write same data |
