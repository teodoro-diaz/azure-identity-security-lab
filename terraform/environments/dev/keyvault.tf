data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "kv-azsec-lab-t01-2026"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
    Purpose     = "Private Secrets Management"
  }
}