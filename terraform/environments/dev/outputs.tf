
output "resource_group_name" {
  description = "Name of the project Resource Group"
  value       = azurerm_resource_group.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "app_service_url" {
  description = "Application Service URL"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "managed_identity_principal_id" {
  description = "System-assigned Managed Identity Principal ID"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Key Vault Private Endpoint Resource ID"
  value       = azurerm_private_endpoint.keyvault.id
}
