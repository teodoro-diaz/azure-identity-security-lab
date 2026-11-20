
resource "azurerm_service_plan" "main" {
  name                = "asp-azsec-lab-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  os_type  = "Linux"
  sku_name = "B1"

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-azsec-lab-t01-2026"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only                                     = true
  public_network_access_enabled                  = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  virtual_network_subnet_id = azurerm_subnet.app_integration.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  app_settings = {
    KEY_VAULT_URL         = "https://${azurerm_key_vault.main.name}.vault.azure.net/"
    KEY_VAULT_SECRET_NAME = "lab-secret"
  }

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
    Purpose     = "Flask Application with Managed Identity"
  }
}
