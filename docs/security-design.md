# Security Design

## 1. Overview

This document describes the security controls implemented in the Azure Identity & Security Lab.

The design follows three main principles:

- Identity-based authentication.
- Least-privilege authorization.
- Private network connectivity to protected services.

Azure App Service accesses Azure Key Vault without storing credentials in the application code.

## 2. Authentication — Managed Identity

The App Service uses a System-assigned Managed Identity.

This identity is automatically associated with the lifecycle of the App Service.

### Security Benefits

- No application-managed username or password.
- No client secret or certificate stored in the application.
- Token-based authentication through Microsoft Entra ID.
- Azure resource identity is managed by the platform.

The Flask application uses:

```python
from azure.identity import DefaultAzureCredential
```

`DefaultAzureCredential` selects the available authentication mechanism according to the execution environment.

In Azure App Service, the configured Managed Identity is used to obtain the access token.

## 3. Authorization — Azure RBAC

Authentication alone does not grant permission to read Key Vault secrets.

Authorization is controlled through Azure RBAC.

### Role Assignment

| Property | Configuration |
|---|---|
| Principal | App Service Managed Identity |
| Role | `Key Vault Secrets User` |
| Scope | Specific Key Vault resource |
| Authorization model | Azure RBAC |

The `Key Vault Secrets User` role allows the application to read secret contents without granting secret-management privileges.

During the lab setup, `Key Vault Secrets Officer` was temporarily assigned to create a test secret. This temporary assignment was subsequently removed.

**Final intended permission:** the App Service Managed Identity retains only `Key Vault Secrets User` on the Key Vault resource.

## 4. Network Security — Private Endpoint

Azure Key Vault is configured with:

```hcl
public_network_access_enabled = false
```

This disables public network access to the Key Vault data plane.

A Private Endpoint establishes private connectivity to the Key Vault service through Azure Private Link.

### Network Configuration

| Component | Configuration |
|---|---|
| Key Vault public access | Disabled |
| Private Endpoint | Enabled |
| Private Endpoint subnet | `10.20.2.0/24` |
| App Service VNet Integration | Enabled |
| Integration subnet | `10.20.1.0/24` |

The App Service uses VNet Integration for outbound access to the private endpoint.

The App Service public HTTPS endpoint is not disabled in this lab. Public application access and private Key Vault connectivity are separate security considerations.

## 5. Private DNS

The solution uses the following Private DNS Zone:

```text
privatelink.vaultcore.azure.net
```

The zone is linked to the Virtual Network and associated with the Private Endpoint.

This enables private name resolution for Key Vault.

The application continues using the standard Key Vault hostname:

```text
https://<key-vault-name>.vault.azure.net/
```

DNS resolution directs the connection through the private endpoint when the application uses the linked network resolution path.

## 6. Secret Management

The Flask application retrieves secrets using the Azure Key Vault SDK.

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
```

The application reads the secret name from its configuration and requests the secret from Key Vault.

### Secret Protection Controls

- No credentials are hardcoded in the application.
- Secret values are not returned in HTTP responses.
- Sensitive values are not intentionally written to application logs.
- Key Vault access is controlled through Azure RBAC.
- Key Vault public network access is disabled.

The `/secret` endpoint returns the retrieval status and secret name, not the secret value.

## 7. Security Layers

| Security Layer | Implemented Control |
|---|---|
| Identity | System-assigned Managed Identity |
| Authentication | Microsoft Entra ID token |
| Authorization | Azure RBAC |
| Least privilege | Key Vault Secrets User |
| Network isolation | Private Endpoint |
| Public access restriction | Key Vault public access disabled |
| Name resolution | Azure Private DNS |
| Application transport | HTTPS only |
| Publishing security | FTP and WebDeploy basic authentication disabled |
| Secret exposure prevention | Secret value excluded from HTTP response |

## 8. Security Considerations and Limitations

The lab demonstrates core identity and network security controls, but it is not a complete production security baseline.

The following items require additional consideration before production use:

- Enable Key Vault purge protection.
- Review the seven-day soft-delete retention configured for the lab.
- Restrict inbound App Service access if public application exposure is not required.
- Consider WAF protection when a public application endpoint is required.
- Configure diagnostic settings and security monitoring.
- Review application logging to prevent sensitive information exposure.
- Establish a formal secret rotation and recovery strategy.

The current Terraform configuration has purge protection disabled. This is a lab configuration and should be reviewed before production deployment.

## 9. Security Validation

The following controls should be validated during deployment:

| Validation | Expected Result |
|---|---|
| App Service Managed Identity | Enabled |
| Managed Identity token acquisition | Successful |
| Key Vault RBAC assignment | `Key Vault Secrets User` |
| Key Vault public network access | Disabled |
| Private Endpoint connection | Approved and connected |
| Private DNS resolution | Resolves to private endpoint |
| Secret retrieval | Successful |
| Secret value in HTTP response | Not exposed |

Evidence must be captured from actual deployment and validation results.

## 10. Security Design Summary

The solution separates authentication, authorization, and network connectivity:

- Managed Identity establishes the application identity.
- Azure RBAC defines the permissions granted to that identity.
- Private Endpoint provides private connectivity to Key Vault.
- Private DNS enables private name resolution.
- Application logic prevents secret values from being exposed through its HTTP response.

This design reduces credential management requirements and limits access to sensitive resources.

---

**Project:** Azure Identity & Security Lab  
**Security Model:** Managed Identity + Azure RBAC + Private Link