resource "kubectl_manifest" "eniconfig" {
  for_each = { for sn in data.aws_subnet.pod : sn.id => sn }

  yaml_body = <<YAML
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${each.value.availability_zone}
spec:
 subnet: ${each.key}
 securityGroups:
 - ${local.pod_security_group_id}
YAML

  depends_on = [aws_eks_addon.vpccni]
}

resource "local_file" "config" {
  count = var.enabled && var.enable_custom_network ? 1 : 0

  content  = ""
  filename = "${path.module}/.terraform/config.yaml"
}

resource "local_file" "kube_ca" {
  count = var.enabled && var.enable_custom_network ? 1 : 0

  content  = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  filename = "${path.module}/.terraform/ca.crt"
}

resource "null_resource" "patch_cni" {
  count = var.enabled && var.enable_custom_network ? 1 : 0

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl set env ds aws-node --server=$KUBESERVER --token=$KUBETOKEN --certificate-authority=$KUBECA -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true ENABLE_PREFIX_DELEGATION=true WARM_PREFIX_TARGET=1 ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone"

    environment = {
      KUBECONFIG = local_file.config[0].filename
      KUBESERVER = data.aws_eks_cluster.cluster.endpoint
      KUBETOKEN  = data.aws_eks_cluster_auth.cluster.token
      KUBECA     = local_file.kube_ca[0].filename
    }
  }

  depends_on = [kubectl_manifest.eniconfig]
}
