
import os
import logging

from flask import Flask, jsonify
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "application": "azure-identity-security-lab"
    }), 200


@app.get("/secret")
def get_secret():
    vault_url = os.getenv("KEY_VAULT_URL")
    secret_name = os.getenv("KEY_VAULT_SECRET_NAME", "lab-secret")

    if not vault_url:
        return jsonify({
            "status": "error",
            "message": "Key Vault configuration is missing"
        }), 500

    try:
        credential = DefaultAzureCredential()

        client = SecretClient(
            vault_url=vault_url,
            credential=credential
        )

        secret = client.get_secret(secret_name)

        # No devolver ni registrar el valor del secreto.
        return jsonify({
            "status": "success",
            "secret_name": secret.name,
            "secret_retrieved": secret.value is not None
        }), 200

    except Exception:
        logger.exception("Key Vault secret retrieval failed")

        return jsonify({
            "status": "error",
            "message": "Unable to retrieve secret from Key Vault"
        }), 500
