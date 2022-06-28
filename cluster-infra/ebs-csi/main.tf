resource "kubernetes_storage_class" "encrypted" {
  count = var.enabled ? 1 : 0

  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    fsType    = "ext4"
    type      = "gp2"
    encrypted = "true"
    kmsKeyId  = "${var.ebs_kms_key_id}"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "local_file" "config" {
  count = var.enabled ? 1 : 0

  content  = ""
  filename = "${path.module}/.terraform/config.yaml"
}

resource "local_file" "kube_ca" {
  count = var.enabled ? 1 : 0

  content  = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  filename = "${path.module}/.terraform/ca.crt"
}

resource "null_resource" "patch_sc" {
  count = var.enabled ? 1 : 0

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/patch-original-sc.sh"

    environment = {
      KUBECONFIG  = local_file.config[0].filename
      KUBESERVER  = data.aws_eks_cluster.cluster.endpoint
      KUBETOKEN   = data.aws_eks_cluster_auth.cluster.token
      KUBECA      = local_file.kube_ca[0].filename
      CLUSTERNAME = var.cluster_name
      SC          = local.initial_storage_class_name
    }
  }
}
