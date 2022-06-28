data "kubernetes_storage_class_v1" "default" {
  metadata {
    name = "gp2"
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
