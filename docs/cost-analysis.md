# Cost Analysis

## 1. Overview

This document identifies the Azure resources that may generate costs in the Azure Identity & Security Lab.

The project uses a development environment to demonstrate Azure App Service, Managed Identity, Key Vault, Private Endpoint, and private networking.

The objective is to identify cost drivers, control resource usage, and prevent unnecessary charges.

## 2. Cost-Generating Resources

| Resource | Configuration | Cost Consideration |
|---|---|---|
| App Service Plan | Linux B1 | Recurring compute cost while provisioned |
| App Service | Python 3.12 | Uses the associated App Service Plan |
| Azure Key Vault | Standard | Operations and applicable service charges |
| Private Endpoint | Key Vault | Recurring endpoint and data-processing charges |
| Private DNS Zone | Key Vault private zone | Hosted DNS zone and query charges |
| Virtual Network | `10.20.0.0/16` | No charge for the VNet itself under standard conditions |
| Subnets | Two subnets | No separate subnet charge |
| Managed Identity | System-assigned | No separate charge for the identity itself |
| Azure RBAC | Role assignment | No separate charge for the assignment itself |
| Resource Group | Development resource group | No direct resource-group charge |

Actual costs depend on the Azure region, subscription agreement, service usage, and current Microsoft pricing.

## 3. Main Cost Drivers

### App Service Plan — Linux B1

The Linux B1 App Service Plan is one of the main recurring cost components.

The plan remains billable while provisioned, even when the application receives little or no traffic.

Cost control:

- Deploy only when required for the lab.
- Avoid leaving the App Service Plan running unnecessarily.
- Review the selected pricing tier before deployment.

### Azure Private Endpoint

The Private Endpoint is another important cost component.

Potential charges include:

- Private Endpoint hourly usage.
- Data processing associated with Private Link.

Cost control:

- Deploy only when validating private connectivity.
- Remove the endpoint when the lab is completed and no longer required.

### Azure Key Vault

Key Vault Standard may generate charges based on service operations and applicable pricing rules.

Cost control:

- Avoid unnecessary secret operations.
- Use only the required secrets for the lab.
- Review the current pricing model before deployment.

### Azure Private DNS

The Private DNS Zone may generate charges for the hosted zone and DNS queries.

Cost control:

- Maintain only the DNS zones required by the architecture.
- Remove unused zones and links after the lab is completed.

## 4. Resources with No Separate Direct Charge

The following components do not normally generate a separate direct charge in this architecture:

- Resource Group.
- Virtual Network.
- Subnets.
- System-assigned Managed Identity.
- Azure RBAC role assignment.

However, associated services and data transfer may still generate charges.

## 5. Deployment Cost-Control Strategy

The following procedure should be followed before every deployment.

### Step 1 — Review Terraform Plan

```bash
terraform plan -out=tfplan
```

Review:

- Resources to be created.
- Resources to be modified.
- Resources to be destroyed.
- App Service Plan SKU.
- Private Endpoint configuration.
- Key Vault configuration.

### Step 2 — Review Azure Pricing

Use the official Microsoft pricing pages to review current rates:

- Azure App Service: https://azure.microsoft.com/pricing/details/app-service/
- Azure Key Vault: https://azure.microsoft.com/pricing/details/key-vault/
- Azure Private Link: https://azure.microsoft.com/pricing/details/private-link/
- Azure DNS: https://azure.microsoft.com/pricing/details/dns/

Prices must be checked for the selected region and applicable subscription.

### Step 3 — Apply Only When Required

```bash
terraform apply tfplan
```

Do not apply the plan until the resources and their expected costs have been reviewed.

### Step 4 — Validate the Deployment

Perform only the required tests:

- App Service health check.
- Managed Identity authentication.
- Key Vault RBAC authorization.
- Private DNS resolution.
- Private Endpoint connectivity.
- Secret retrieval.

### Step 5 — Destroy the Lab

When testing is complete:

```bash
terraform destroy
```

Review the destruction plan before confirming the operation.

### Step 6 — Verify Resource Cleanup

Check that the deployed resources have been removed.

```bash
az resource list \
  --resource-group rg-az-security-lab-dev \
  --output table
```

Also verify that no billable resources associated with the lab remain outside the Terraform-managed resource group.

## 6. Cost Risks and Considerations

| Risk | Impact | Mitigation |
|---|---|---|
| App Service Plan left running | Recurring compute charges | Destroy after testing |
| Private Endpoint left provisioned | Recurring endpoint charges | Remove after testing |
| Unnecessary Key Vault operations | Additional operation charges | Limit test operations |
| DNS resources left unused | Unnecessary DNS charges | Remove unused zones |
| Additional resources created manually | Resources may remain after Terraform destroy | Review Azure Resource Group |
| Incorrect Terraform state | Cleanup may be incomplete | Validate state and Azure resources |

**Important:** Key Vault soft-delete can retain a deleted vault in a recoverable state. Review the vault's lifecycle and applicable billing implications during cleanup. Do not assume that `terraform destroy` immediately removes every recoverable or soft-deleted service object.

## 7. Cost Optimization Recommendations

For this development lab:

1. Use the B1 App Service Plan only when required.
2. Avoid unnecessary deployment time.
3. Validate all security components in a single planned test session.
4. Destroy the infrastructure after validation.
5. Review Azure Cost Management after deployment.
6. Avoid creating additional services that are not required by the architecture.
7. Verify resource cleanup after Terraform destroy.

## 8. Cost Assessment

The main recurring cost risks in this lab are:

- Azure App Service Plan.
- Azure Private Endpoint.
- Azure Key Vault operations.
- Azure Private DNS Zone and queries.

The actual deployment cost must be calculated using current Microsoft pricing and the selected Azure region.

No fixed monthly or hourly cost is stated in this document because pricing can change and depends on actual resource usage.

## 9. Conclusion

The lab is designed to minimize unnecessary Azure consumption by using a controlled deployment and cleanup process.

Terraform provides repeatable provisioning and destruction, while plan review and Azure Cost Management help identify potential charges.

The recommended operational approach is:

**Plan → Review Costs → Apply → Validate → Destroy → Verify Cleanup**

---

**Project:** Azure Identity & Security Lab  
**Cloud Provider:** Microsoft Azure  
**Cost Strategy:** Controlled Deployment and Resource Cleanup