# Diseño Técnico: Autenticación Segura y Service Principals

## Flujo de Identidades

1. **Desarrollo Local:** Autenticación mediante credenciales de Azure CLI (`DefaultAzureCredential`).
2. **Producción (ETL / Data Factory):** Uso de Managed Identities (Identidades
 Administradas) o Service Principals con rotación automática de secretos
 mediante Key Vault.
