# Flask Application — Azure Identity & Security Lab

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-Web%20Framework-000000?logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Azure Identity](https://img.shields.io/badge/Azure-Managed%20Identity-0078D4?logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/app-service/overview-managed-identity)
[![Key Vault](https://img.shields.io/badge/Azure-Key%20Vault-0078D4?logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/key-vault/)

A Python Flask application deployed on **Azure App Service** to demonstrate secure secret retrieval from **Azure Key Vault** using Microsoft Entra ID and System-assigned Managed Identity.

## 🎯 Application Overview

The application retrieves secrets from Azure Key Vault without storing credentials in the source code.

Authentication is handled through `DefaultAzureCredential`, while Azure RBAC controls the permissions granted to the App Service identity.

## 🧰 Technology Stack

| Technology | Purpose |
|---|---|
| Python 3.12 | Application runtime |
| Flask | Web framework |
| Gunicorn | WSGI application server |
| Azure Identity SDK | Authentication |
| Azure Key Vault Secrets SDK | Secret retrieval |
| Azure App Service | Application hosting |
| Managed Identity | Passwordless authentication |
| Azure RBAC | Authorization |

## 📂 Application Structure

```text
app/
├── app.py
├── requirements.txt
└── README.md
```

## 🔌 API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/health` | GET | Checks application health |
| `/secret` | GET | Retrieves a secret from Azure Key Vault |

### Health Check

Request:

```http
GET /health
```

Expected response:

```json
{
  "application": "azure-identity-security-lab",
  "status": "healthy"
}
```

### Secret Retrieval

Request:

```http
GET /secret
```

The application uses `DefaultAzureCredential` and `SecretClient` to retrieve the configured secret from Azure Key Vault.

Expected response:

```json
{
  "secret_name": "lab-secret",
  "secret_retrieved": true,
  "status": "success"
}
```

**Security note:** The secret value is never returned to the API client or written to application logs.

## ⚙️ Environment Variables

| Variable | Description |
|---|---|
| `KEY_VAULT_URL` | Azure Key Vault endpoint |
| `KEY_VAULT_SECRET_NAME` | Name of the secret to retrieve |

Example:

```bash
export KEY_VAULT_URL="https://<key-vault-name>.vault.azure.net/"
export KEY_VAULT_SECRET_NAME="lab-secret"
```

Do not store credentials or secret values in application configuration or source control.

## 💻 Local Development

### 1. Create a virtual environment

From the repository root:

```bash
python -m venv .venv
```

Activate it in Git Bash:

```bash
source .venv/Scripts/activate
```

### 2. Install dependencies

```bash
pip install -r app/requirements.txt
```

### 3. Authenticate to Azure

For local development, `DefaultAzureCredential` can use the Azure CLI credentials.

```bash
az login
az account show
```

The signed-in identity must have the required permissions to access the Key Vault.

### 4. Configure environment variables

```bash
export KEY_VAULT_URL="https://<key-vault-name>.vault.azure.net/"
export KEY_VAULT_SECRET_NAME="lab-secret"
```

### 5. Run the application

```bash
python -m flask --app app.app run
```

The application will be available at:

```text
http://127.0.0.1:5000
```

Test the health endpoint:

```bash
curl http://127.0.0.1:5000/health
```

**Note:** Local `/secret` testing also requires network connectivity to the Key Vault Private Endpoint. An Azure CLI login alone does not provide private network access.

## 🔐 Identity & Security

### Managed Identity

In Azure App Service, the application uses a System-assigned Managed Identity.

This allows the application to obtain Microsoft Entra ID access tokens without storing usernames, passwords, client secrets or certificates.

### Azure RBAC

The App Service Managed Identity is assigned:

- **Role:** Key Vault Secrets User
- **Scope:** Specific Azure Key Vault resource

This role provides the permissions required to read secrets.

### Private Connectivity

The application-to-Key Vault communication uses:

- Azure Private Endpoint.
- Azure Private DNS Zone.
- App Service VNet Integration.
- Key Vault public network access disabled.

## 🧪 Validation Scenarios

The lab validation covers:

- App Service application availability.
- `/health` endpoint returning HTTP 200.
- Private DNS resolution for Azure Key Vault.
- Private Endpoint connectivity.
- Managed Identity token acquisition.
- Azure RBAC authorization.
- Successful retrieval of the test secret.
- `/secret` endpoint returning HTTP 200 without exposing the secret value.

## 🛡️ Security Principles

- No credentials embedded in source code.
- No secret values returned in HTTP responses.
- No sensitive values written to application logs.
- Least-privilege authorization through Azure RBAC.
- Private connectivity to Azure Key Vault.
- Managed Identity for passwordless authentication.

---

**Project:** Azure Identity & Security Lab

**Repository:** [azure-identity-security-lab](https://github.com/teodoro-diaz/azure-identity-security-lab)