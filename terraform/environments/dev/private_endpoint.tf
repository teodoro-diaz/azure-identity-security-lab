
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-kv-security-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "psc-keyvault-security-dev"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-keyvault"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
    Purpose     = "Private Key Vault Connectivity"
  }
}
