output "cert_manager_deployment_name" {
  description = "Kubernetes metadata name for the Cert Manager deployment."
  value       = var.enabled ? kubernetes_deployment.cert_manager[0].metadata[0].name : ""
}

output "ca_injector_deployment_name" {
  description = "Kubernetes metadata name for the Cert Manager Injector deployment."
  value       = var.enabled ? kubernetes_deployment.cainjector[0].metadata[0].name : ""
}

output "ca_webhook_deployment_name" {
  description = "Kubernetes metadata name for the Cert Manager Webhook deployment."
  value       = var.enabled ? kubernetes_deployment.webhook[0].metadata[0].name : ""
}
