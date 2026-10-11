# Guía de Despliegue - BigQuery Fintech Pipeline

## 🚀 Pasos para la Ejecución en Producción

1. Configurar las credenciales de autenticación de Google Cloud (`gcloud auth login`).
2. Validar las variables de entorno en el archivo `.env`.
3. Ejecutar el script SQL de aprovisionamiento en la consola o CLI de BigQuery:

   ```bash
   bq query --use_legacy_sql=false < P5_BigQuery_Fintech/scripts/Scrip_BigQuery.sql
   ```
