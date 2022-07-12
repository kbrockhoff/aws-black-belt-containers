# Kevin Brockhoff's Capstone Project
#### APN Project Black Belt - Containers Track

Production-ready EKS cluster provisioned exclusively via GitOps with the
following features:

* All provisioning and deployments via GitOps approach using GitHub Actions and ArgoCD.
* Latest EKS version with cluster provisioned via EKS Blueprints.
* Cluster logs to CloudWatch encrypted with CMK.
* Latest version of all EKS-managed addons provisioned via EKS Blueprints.
* VPC CNI networking configured to use custom networking with pods running in separate subnets with 100.64.x CIDRs.
* Default StorageClass switched to EBS encrypted with CMK.
* aws-for-fluent-bit forwarding all logs to CloudWatch split into three different CMK-encrypted log groups.
  * applications - logs of all non-Kubernetes platform pods
  * dataplane - logs of Kubernetes platform pods and Kubernetes-related systemd services
  * host - logs of underlying host VM
* Terraform-provisioned ALB exposed to Internet protected by ACM and WAF.
  * Target group managed by ALB Ingress Controller using TargetGroupBinding.
* Default ingress functionality using ingress-nginx.
  * Used primarily for platform services such as ArgoCD and Grafana.
* APIGateway functionality managed by Gloo Edge.
* Node autoscaling managed by Karpenter with a single Provisioner.
* Velero used to manage backups.
* App-of-apps pattern used to deploy additional platform-services via ArgoCD.

