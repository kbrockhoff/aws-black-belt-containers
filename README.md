# Kevin Brockhoff's Capstone Project
#### APN Project Black Belt - Containers Track

Production-ready EKS cluster provisioned exclusively via GitOps with the
following features:

* Latest EKS version with cluster provisioned via EKS Blueprints.
* Cluster logs to CloudWatch encrypted with CMK.
* Latest version of all EKS-managed addons provisioned via EKS Blueprints.
* VPC CNI networking configured to use custom networking with pods running in separate subnets with 100.64.x CIDRs.
* Default StorageClass switched to EBS encrypted with CMK.
* aws-for-fluent-bit forwarding all logs to CloudWatch split into three different CMK-encrypted log groups.

