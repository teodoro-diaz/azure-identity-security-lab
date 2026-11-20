resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                 = "link-keyvault-security-dev"
  private_dns_zone_id  = azurerm_private_dns_zone.keyvault.id
  virtual_network_id   = azurerm_virtual_network.main.id
  registration_enabled = false
}