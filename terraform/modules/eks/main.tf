# =========================================================
# LOCALS
# =========================================================

locals {

  common_tags = {

    Project     = "devops-infrastructure"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# =========================================================
# EKS CLUSTER IAM ROLE
# =========================================================

resource "aws_iam_role" "eks_cluster_role" {

  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {

          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# =========================================================
# EKS NODE ROLE
# =========================================================

resource "aws_iam_role" "eks_node_role" {

  name = "${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# =========================================================
# NODE ROLE POLICIES
# =========================================================

resource "aws_iam_role_policy_attachment" "node_worker" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# =========================================================
# EKS CLUSTER
# =========================================================

resource "aws_eks_cluster" "cluster" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.kubernetes_version

  vpc_config {

    subnet_ids = var.private_subnets

    endpoint_private_access = true

    endpoint_public_access  = true
  }

  depends_on = [

    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = merge(

    local.common_tags,

    {
      Name = var.cluster_name
    }
  )
}

# =========================================================
# NODE GROUP
# =========================================================

resource "aws_eks_node_group" "nodes" {

  cluster_name = aws_eks_cluster.cluster.name

  node_group_name = var.node_group_name

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = var.private_subnets

  instance_types = var.instance_types

  capacity_type = "ON_DEMAND"

  ami_type = "AL2023_x86_64_STANDARD"

  disk_size = 30

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size
  }

  update_config {

    max_unavailable = 1
  }

  depends_on = [

    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]

  tags = merge(

    local.common_tags,

    {
      Name = var.node_group_name
    }
  )
}

# =========================================================
# OIDC PROVIDER
# =========================================================

data "tls_certificate" "oidc" {

  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.oidc.certificates[0].sha1_fingerprint
  ]

  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = merge(

    local.common_tags,

    {
      Name = "${var.environment}-eks-oidc"
    }
  )
}

# =========================================================
# EBS CSI IAM ROLE (IRSA)
# =========================================================

resource "aws_iam_role" "ebs_csi_role" {

  name = "${var.environment}-ebs-csi-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = aws_iam_openid_connect_provider.oidc.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${replace(
              aws_iam_openid_connect_provider.oidc.url,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = merge(

    local.common_tags,

    {
      Name = "${var.environment}-ebs-csi-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {

  role = aws_iam_role.ebs_csi_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# =========================================================
# EKS ADDONS
# =========================================================

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = aws_eks_cluster.cluster.name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.nodes
  ]
}

resource "aws_eks_addon" "coredns" {

  cluster_name = aws_eks_cluster.cluster.name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.nodes
  ]
}

resource "aws_eks_addon" "kube_proxy" {

  cluster_name = aws_eks_cluster.cluster.name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.nodes
  ]
}

# =========================================================
# EBS CSI ADDON
# =========================================================

resource "aws_eks_addon" "ebs_csi" {

  cluster_name = aws_eks_cluster.cluster.name

  addon_name = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi_role.arn

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [

    aws_eks_node_group.nodes,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]

  timeouts {

    create = "40m"

    delete = "20m"
  }

  tags = merge(

    local.common_tags,

    {
      Name = "${var.environment}-ebs-csi-addon"
    }
  )
}