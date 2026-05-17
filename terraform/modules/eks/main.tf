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

# =========================================================
# EKS CLUSTER IAM POLICIES
# =========================================================

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster_role.name

  policy_arn =
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# =========================================================
# EKS NODE IAM ROLE
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
# NODE IAM POLICIES
# =========================================================

resource "aws_iam_role_policy_attachment" "worker_node_policy" {

  role = aws_iam_role.eks_node_role.name

  policy_arn =
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {

  role = aws_iam_role.eks_node_role.name

  policy_arn =
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {

  role = aws_iam_role.eks_node_role.name

  policy_arn =
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# =========================================================
# EKS CLUSTER
# =========================================================

resource "aws_eks_cluster" "main" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster_role.arn

  version = "1.31"

  vpc_config {

    subnet_ids = var.private_subnets

    endpoint_private_access = true

    endpoint_public_access = true
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
# EKS NODE GROUP
# =========================================================

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = var.node_group_name

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = var.private_subnets

  instance_types = var.instance_types

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size
  }

  capacity_type = "ON_DEMAND"

  ami_type = "AL2023_x86_64_STANDARD"

  disk_size = 30

  depends_on = [

    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]

  tags = merge(

    local.common_tags,

    {
      Name = var.node_group_name
    }
  )
}

# =========================================================
# EKS ADDONS
# =========================================================

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"
}