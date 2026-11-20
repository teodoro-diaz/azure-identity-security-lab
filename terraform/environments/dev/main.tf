
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "azure-identity-security-lab"
    ManagedBy   = "Terraform"
    Purpose     = "Identity and Security Lab"
  }
}
