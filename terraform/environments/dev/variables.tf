variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Project resource group"
  type        = string
  default     = "rg-az-security-lab-dev"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "key_vault_secret_name" {
  description = "Name of the lab secret"
  type        = string
  default     = "lab-secret"
}