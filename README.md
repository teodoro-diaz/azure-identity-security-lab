# Azure Identity & Security Lab

## Implementación de Azure App Service con Managed Identity, Azure Key Vault y Private Endpoint

[![Azure](https://img.shields.io/badge/Cloud-Microsoft%20Azure-0078D4)](https://azure.microsoft.com/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Language-Python%203.12-3776AB)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Framework-Flask-000000)](https://flask.palletsprojects.com/)

## 1. Descripción del proyecto

Este proyecto implementa una arquitectura de seguridad en Microsoft Azure para desplegar una aplicación web en Azure App Service que consume secretos almacenados en Azure Key Vault, sin utilizar credenciales almacenadas directamente en el código de la aplicación.

La solución utiliza **System-assigned Managed Identity** para la autenticación, **Azure RBAC** para controlar los permisos y **Private Endpoint** para establecer conectividad privada entre App Service y Key Vault.

La infraestructura se aprovisiona mediante Terraform (Infrastructure as Code), mientras que la aplicación se desarrolla con Python y Flask.

El objetivo principal es demostrar cómo implementar una arquitectura basada en identidad, mínimo privilegio y conectividad privada en Azure.

## 2. Objetivos

- Implementar infraestructura Azure mediante Terraform.
- Desplegar una aplicación Python Flask en Azure App Service.
- Configurar autenticación mediante Managed Identity.
- Aplicar autorización mediante Azure RBAC.
- Restringir el acceso público a Azure Key Vault.
- Implementar Private Endpoint y Private DNS.
- Integrar App Service con una VNet.
- Validar la lectura de secretos sin exponer sus valores.
- Documentar pruebas de conectividad, autenticación y autorización.

## 3. Arquitectura

### Componentes principales

| Componente | Nombre | Función |
|---|---|---|
| Resource Group | `rg-az-security-lab-dev` | Agrupación de recursos |
| Virtual Network | `vnet-security-dev` | Red privada |
| Subnet App Integration | `snet-app-integration` | Integración de salida de App Service |
| Subnet Private Endpoint | `snet-private-endpoint` | Conectividad privada con Key Vault |
| App Service Plan | `asp-azsec-lab-dev` | Plan Linux B1 |
| App Service | `app-azsec-lab-t01-2026` | Ejecución de Flask |
| Managed Identity | System-assigned | Identidad de la aplicación |
| Key Vault | `kv-azsec-lab-t01-2026` | Almacenamiento de secretos |
| Private Endpoint | `pe-kv-security-dev` | Acceso privado a Key Vault |
| Private DNS Zone | `privatelink.vaultcore.azure.net` | Resolución DNS privada |
| Role Assignment | Key Vault Secrets User | Autorización de lectura |

### Diagrama lógico

```text
                         INTERNET
                            |
                            | HTTPS
                            v
                 +----------------------+
                 |   Azure App Service  |
                 |      Linux B1        |
                 |                      |
                 |    Python / Flask    |
                 |                      |
                 |  System-assigned MI  |
                 +----------+-----------+
                            |
                            | VNet Integration
                            |
                            v
                 +----------------------+
                 |    Virtual Network   |
                 |    10.20.0.0/16      |
                 |                      |
                 |  snet-app-integration
                 |      10.20.1.0/24    |
                 |                      |
                 |  snet-private-endpoint
                 |      10.20.2.0/24    |
                 +----------+-----------+
                            |
                            | Private Link
                            v
                 +----------------------+
                 |    Private Endpoint  |
                 |      10.20.2.4       |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |     Azure Key Vault  |
                 |                      |
                 |  Public access: OFF  |
                 |  Authorization: RBAC |
                 +----------------------+

                 Private DNS:
                 privatelink.vaultcore.azure.net
```

El acceso web a App Service permanece público mediante HTTPS en esta versión del laboratorio. El acceso de la aplicación hacia Key Vault se realiza mediante conectividad privada.

## 4. Seguridad e identidad

### Managed Identity

Se utiliza una identidad administrada asignada por el sistema (System-assigned Managed Identity).

Esto permite que App Service obtenga tokens de Microsoft Entra ID sin almacenar usuarios, contraseñas, client secrets o certificados en el código.

### Azure RBAC

Se habilita el modelo de autorización RBAC de Key Vault.

Rol utilizado:

- `Key Vault Secrets User`: permite leer el contenido de los secretos.

Durante las pruebas se asignó temporalmente `Key Vault Secrets Officer` para crear un secreto de laboratorio. Posteriormente se retiró esta asignación.

**Estado final:** la Managed Identity conserva únicamente `Key Vault Secrets User` sobre el recurso Key Vault.

### Restricción de red

- Public Network Access de Key Vault deshabilitado.
- Private Endpoint habilitado.
- Private DNS Zone vinculada a la VNet.
- App Service integrado con la VNet para conectividad de salida.

## 5. Aplicación Flask

La aplicación implementa dos endpoints:

| Endpoint | Función |
|---|---|
| `/health` | Comprueba el estado de la aplicación |
| `/secret` | Recupera un secreto desde Azure Key Vault |

La autenticación se implementa mediante:

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
```

El cliente de Key Vault utiliza `DefaultAzureCredential`, permitiendo utilizar las credenciales disponibles en el entorno de ejecución.

La aplicación no devuelve el valor del secreto en la respuesta HTTP ni lo registra en los logs.

Ejemplo de respuesta de `/secret`:

```json
{
  "secret_name": "lab-secret",
  "secret_retrieved": true,
  "status": "success"
}
```

## 6. Infraestructura como código

Terraform administra la infraestructura mediante archivos HCL organizados por responsabilidad.

Directorio:

```text
terraform/
└── environments/
    └── dev/
        ├── versions.tf
        ├── provider.tf
        ├── variables.tf
        ├── terraform.tfvars.example
        ├── main.tf
        ├── networking.tf
        ├── keyvault.tf
        ├── private_dns.tf
        ├── private_endpoint.tf
        ├── app_service.tf
        ├── identity.tf
        ├── rbac.tf
        └── outputs.tf
```

Los archivos se separan para facilitar el mantenimiento, la revisión y la evolución de la infraestructura.

### Comandos principales

Inicializar Terraform:

```bash
terraform init
```

Validar configuración:

```bash
terraform fmt -recursive
terraform validate
```

Generar plan:

```bash
terraform plan -out=tfplan
```

Aplicar infraestructura:

```bash
terraform apply tfplan
```

Consultar recursos administrados:

```bash
terraform state list
```

Consultar outputs:

```bash
terraform output
```

Eliminar infraestructura:

```bash
terraform destroy
```

**Importante:** antes de ejecutar `apply`, revisar el plan y los costos asociados a los recursos. No publicar archivos de State, planes ni variables que contengan información sensible.

## 7. Pruebas y validaciones realizadas

### 7.1 Estado de App Service

Se comprobó que la aplicación estuviera ejecutándose:

```bash
az webapp show \
  --resource-group rg-az-security-lab-dev \
  --name app-azsec-lab-t01-2026 \
  --query state \
  -o tsv
```

Resultado esperado:

```text
Running
```

### 7.2 Health Check

```bash
curl -i \
  https://app-azsec-lab-t01-2026.azurewebsites.net/health
```

Resultado:

```text
HTTP/1.1 200 OK
```

### 7.3 Resolución DNS privada

Desde la sesión SSH de App Service:

```bash
getent hosts kv-azsec-lab-t01-2026.vault.azure.net
```

Se comprobó la resolución hacia la dirección privada del Private Endpoint.

### 7.4 Conectividad con Key Vault

Se realizó una solicitud HTTPS sin token para comprobar conectividad.

La respuesta `401 Unauthorized` confirmó que se alcanzaba el servicio, pero faltaba autenticación.

La cabecera de red de Key Vault permitió identificar:

```text
conn_type=PrivateLink
addr=10.20.1.254
```

### 7.5 Autenticación mediante Managed Identity

Se obtuvo un token mediante el endpoint de Managed Identity de App Service, sin mostrar ni almacenar el token en el repositorio.

Se realizó una consulta autenticada a Key Vault.

Resultado:

```text
HTTP/1.1 200 OK
```

### 7.6 Autorización RBAC

Se comprobó que la identidad podía consultar los secretos utilizando `Key Vault Secrets User`.

También se probó la creación de un secreto con `Key Vault Secrets Officer` asignado temporalmente.

Posteriormente se eliminó el permiso de administración.

### 7.7 Prueba de extremo a extremo

Se ejecutó:

```bash
curl -i \
  https://app-azsec-lab-t01-2026.azurewebsites.net/secret
```

Resultado:

```text
HTTP/1.1 200 OK
```

Respuesta:

```json
{
  "secret_name": "lab-secret",
  "secret_retrieved": true,
  "status": "success"
}
```

Esta prueba confirmó la integración entre Flask, Managed Identity, Azure RBAC, Private Endpoint y Key Vault.

## 8. Troubleshooting y aprendizajes

Durante la implementación se abordaron los siguientes escenarios:

| Escenario | Diagnóstico o solución |
|---|---|
| Error al validar Terraform | Corrección de argumentos y atributos del provider |
| Nombre de App Service | Validación de disponibilidad antes del despliegue |
| Cuota regional B1 | Solicitud de incremento de cuota y revisión de disponibilidad |
| App Service no iniciaba | Revisión de logs de contenedor y configuración de Gunicorn |
| Key Vault respondía 404 | Diferenciación entre endpoint raíz y API de secretos |
| Key Vault respondía 401 | Token Bearer ausente |
| Key Vault respondía 403 | Revisión de identidad y permisos RBAC |
| Azure CLI MissingSubscription | Verificación del contexto de suscripción y uso del Portal para la asignación temporal |

Aprendizaje clave:

**Private Endpoint proporciona conectividad privada, Managed Identity proporciona identidad y RBAC determina las operaciones autorizadas. Son controles diferentes y complementarios.**

## 9. Control de costos

Este laboratorio utiliza servicios de Azure que pueden generar cargos:

- Azure App Service Plan B1.
- Azure Private Endpoint.
- Azure Key Vault por operaciones.
- Azure Private DNS Zone y consultas DNS.

Los recursos se desplegaron para realizar pruebas controladas y se contempla su eliminación al finalizar el laboratorio.

La eliminación mediante Terraform debe verificarse posteriormente en Azure Portal y Azure CLI.

Key Vault utiliza Soft Delete, por lo que su eliminación puede dejar el recurso recuperable durante el período de retención configurado.

No se debe asumir que todos los elementos asociados desaparecen inmediatamente al ejecutar `terraform destroy`.

## 10. Estructura del repositorio

```text
azure-identity-security-lab/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── README.md
│
├── docs/
│   ├── architecture.md
│   ├── cost-analysis.md
│   └── security-design.md
│
├── terraform/
│   └── environments/
│       └── dev/
│           └── *.tf
│
├── .gitignore
└── README.md
```

## 11. Tecnologías utilizadas

- Microsoft Azure
- Azure App Service
- Azure Key Vault
- Azure Managed Identity
- Microsoft Entra ID
- Azure RBAC
- Azure Virtual Network
- Azure Private Endpoint
- Azure Private DNS
- Terraform
- Python 3.12
- Flask
- Gunicorn
- Azure CLI
- Git y GitHub

## 12. Autor y repositorio
**Teodoro Diaz**<br>
Cloud & Infrastructure Engineer<br>
[GitHub](https://github.com/teodoro-diaz) |
[LinkedIn](https://www.linkedin.com/in/teodorodiazcha/)

---

**Objetivo alcanzado:** implementar y validar una aplicación web en Azure que consume secretos de Key Vault mediante identidad administrada, autorización RBAC de mínimo privilegio y conectividad privada, sin credenciales almacenadas en el código.
