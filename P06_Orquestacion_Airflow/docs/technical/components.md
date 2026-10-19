# Guía de Solución de Problemas (Troubleshooting) - Módulo P6

* **Problema 1: Contenedores detenidos por fallo en Base de Datos**
  * *Síntoma:* El webserver o scheduler se apagan de inmediato al iniciar.
  * *Solución:* Validar el estado del servicio de salud de Postgres con
    `docker compose logs postgres` y asegurar que el contenedor
    `airflow-init` haya concluido exitosamente las migraciones.
* **Problema 2: El DAG no aparece en la interfaz gráfica**
  * *Síntoma:* La lista de DAGs en el puerto 8080 está vacía.
  * *Solución:* Comprobar que el archivo esté en la carpeta `dags/` y
    revisar errores de sintaxis en Python ejecutando
    `python -m py_compile dags/portfolio_etl_dag.py`.

