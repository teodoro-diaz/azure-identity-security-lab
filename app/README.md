# Aplicación Flask — Azure Identity & Security Lab

## 1. Descripción

Aplicación web desarrollada en Python con Flask para demostrar la integración segura entre Azure App Service y Azure Key Vault mediante Microsoft Entra ID y Managed Identity.

El objetivo es consumir secretos almacenados en Azure Key Vault sin incluir credenciales directamente en el código fuente.

## 2. Tecnologías utilizadas

- Python 3.12
- Flask
- Gunicorn
- Azure Identity SDK
- Azure Key Vault Secrets SDK
- Azure App Service (Linux)
- System-assigned Managed Identity

## 3. Estructura de archivos

```text
app/
├── app.py
├── requirements.txt
└── README.md
```

## 4. Endpoints disponibles

| Endpoint | Método | Descripción |
|---|---|---|
| `/health` | GET | Verifica el estado de la aplicación. |
| `/secret` | GET | Recupera un secreto desde Azure Key Vault utilizando la identidad administrada. |

### Health Check

Permite comprobar que la aplicación está operativa.

Respuesta esperada:

```json
{
  "application": "azure-identity-security-lab",
  "status": "healthy"
}
```

### Secret Retrieval

Consulta un secreto en Azure Key Vault utilizando `DefaultAzureCredential`.

La aplicación no devuelve el valor del secreto al cliente. Solamente informa si pudo recuperarlo correctamente.

Respuesta esperada:

```json
{
  "secret_name": "lab-secret",
  "secret_retrieved": true,
  "status": "success"
}
```

## 5. Variables de entorno

| Variable | Descripción |
|---|---|
| `KEY_VAULT_URL` | URL del Azure Key Vault. |
| `KEY_VAULT_SECRET_NAME` | Nombre del secreto que se desea consultar. |

Ejemplo:

```bash
export KEY_VAULT_URL="https://<key-vault-name>.vault.azure.net/"
export KEY_VAULT_SECRET_NAME="lab-secret"
```

No almacenar secretos ni credenciales en estas variables.

## 6. Ejecución local

Crear y activar un entorno virtual:

```bash
python -m venv .venv
source .venv/Scripts/activate
```

Instalar dependencias:

```bash
pip install -r app/requirements.txt
```

Ejecutar la aplicación:

```bash
python -m flask --app app.app run
```

La aplicación estará disponible en:

```text
http://127.0.0.1:5000
```

## 7. Seguridad e identidad

La aplicación utiliza `DefaultAzureCredential` para obtener credenciales de autenticación.

En Azure App Service se utiliza una System-assigned Managed Identity.

El acceso a Key Vault se controla mediante Azure RBAC:

- Identidad: Managed Identity del App Service.
- Rol: Key Vault Secrets User.
- Scope: recurso específico de Azure Key Vault.

La conectividad privada se implementa mediante:

- Azure Private Endpoint.
- Azure Private DNS Zone.
- App Service VNet Integration.

## 8. Validaciones realizadas

- Aplicación desplegada en Azure App Service Linux.
- Endpoint `/health` validado con HTTP 200.
- Resolución DNS privada de Azure Key Vault.
- Conectividad hacia Key Vault mediante Private Endpoint.
- Obtención de token mediante Managed Identity.
- Acceso autorizado a la API de secretos de Key Vault.
- Recuperación exitosa del secreto de prueba.
- Endpoint `/secret` validado con HTTP 200.

## 9. Consideraciones de seguridad

- No almacenar credenciales en el código fuente.
- No publicar valores de secretos en respuestas HTTP.
- Aplicar mínimo privilegio mediante Azure RBAC.
- Restringir el acceso público a Key Vault.
- Utilizar conectividad privada para acceder a los servicios protegidos.
- Evitar registrar información sensible en los logs.

---

**Proyecto:** Azure Identity & Security Lab  
**Repositorio:** https://github.com/Chadicito/azure-identity-security-lab