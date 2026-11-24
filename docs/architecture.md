# Architecture Design

## 1. Overview

This document describes the architecture of the Azure Identity & Security Lab.

The solution deploys a Python Flask application on Azure App Service and enables secure access to Azure Key Vault using Managed Identity, Azure RBAC, Private Endpoint, and Private DNS.

Infrastructure is provisioned and managed through Terraform.

## 2. Architecture Objectives

- Deploy an Azure App Service Linux application.
- Implement identity-based authentication using System-assigned Managed Identity.
- Control access to Key Vault through Azure RBAC.
- Disable public network access to Key Vault.
- Establish private connectivity using Azure Private Endpoint.
- Configure private name resolution through Azure Private DNS.
- Integrate App Service with an Azure Virtual Network.
- Retrieve secrets without exposing their values.

## 3. Azure Components

| Component | Configuration | Purpose |
|---|---|---|
| Resource Group | `rg-az-security-lab-dev` | Resource organization |
| Virtual Network | `10.20.0.0/16` | Private network |
| App Integration Subnet | `10.20.1.0/24` | App Service VNet Integration |
| Private Endpoint Subnet | `10.20.2.0/24` | Private connectivity |
| App Service Plan | Linux B1 | Application hosting |
| App Service | Python 3.12 / Flask | Application execution |
| Managed Identity | System-assigned | Application authentication |
| Key Vault | Standard | Secret management |
| Private Endpoint | Key Vault | Private service connectivity |
| Private DNS Zone | `privatelink.vaultcore.azure.net` | Private DNS resolution |
| RBAC Assignment | Key Vault Secrets User | Secret read authorization |

## 4. Network Design

The solution uses a Virtual Network with the address space `10.20.0.0/16`.

Two dedicated subnets separate the network integration and private endpoint functions.

### App Service Integration Subnet

- Subnet: `snet-app-integration`
- Address range: `10.20.1.0/24`
- Delegation: `Microsoft.Web/serverFarms`
- Purpose: Outbound connectivity from App Service to resources accessible through the VNet.

### Private Endpoint Subnet

- Subnet: `snet-private-endpoint`
- Address range: `10.20.2.0/24`
- Purpose: Hosts the private endpoint associated with Azure Key Vault.

The two subnets have separate responsibilities and are not interchangeable.

## 5. Application Connectivity

The application is hosted on Azure App Service Linux and uses VNet Integration for outbound connectivity to the Virtual Network.

The connection to Key Vault follows this logical flow:

1. The Flask application requests a secret.
2. App Service obtains an access token using its Managed Identity.
3. The application resolves the Key Vault hostname.
4. Private DNS resolves the service to its private endpoint address.
5. Traffic reaches Key Vault through Azure Private Link.
6. Key Vault evaluates the identity permissions through Azure RBAC.
7. The secret is returned to the application if authorization succeeds.

The App Service web endpoint remains publicly accessible over HTTPS in this lab. This is intentional and separate from the private connectivity used to access Key Vault.

## 6. Identity and Authorization Flow

The application uses `DefaultAzureCredential` through the Azure Identity SDK.

In Azure App Service, the System-assigned Managed Identity provides the application identity.

The identity receives the `Key Vault Secrets User` role at the Key Vault resource scope.

This separates authentication from authorization:

- Authentication: Managed Identity obtains an access token.
- Authorization: Azure RBAC determines whether the identity can read secrets.

## 7. DNS Design

The solution uses the Azure Private DNS Zone:

`privatelink.vaultcore.azure.net`

The zone is linked to the Virtual Network and associated with the Private Endpoint through a DNS zone group.

This allows the application to use the standard Key Vault hostname while private DNS provides the private endpoint resolution.

## 8. Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/health` | Returns application health status |
| `/secret` | Retrieves a secret from Azure Key Vault |

The `/secret` endpoint does not return the secret value in its HTTP response.

## 9. Design Decisions

| Decision | Rationale |
|---|---|
| App Service | Managed application hosting |
| System-assigned Managed Identity | Avoids application-managed credentials |
| Azure RBAC | Centralized authorization |
| Private Endpoint | Private connectivity to Key Vault |
| Private DNS | Private service name resolution |
| Separate subnets | Network responsibility separation |
| Terraform | Repeatable infrastructure provisioning |

## 10. Architecture Scope and Limitations

This implementation is a development lab designed to demonstrate identity, authorization, and private service connectivity.

The following characteristics are intentional:

- The App Service endpoint remains publicly accessible over HTTPS.
- Key Vault public network access is disabled.
- Key Vault access uses Private Endpoint.
- The solution does not implement multi-region disaster recovery.
- The solution does not include a production-grade ingress architecture such as Application Gateway or Azure Front Door.

These capabilities can be evaluated in a future production-oriented architecture.

## 11. Infrastructure Management

Terraform manages the Azure resources and their dependencies.

Main operations:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform state list
terraform destroy
```

Terraform plans must be reviewed before applying changes.

---

**Project:** Azure Identity & Security Lab  
**Platform:** Microsoft Azure  
**Infrastructure as Code:** Terraform