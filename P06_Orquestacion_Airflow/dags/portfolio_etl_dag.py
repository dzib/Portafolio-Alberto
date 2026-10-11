from airflow import DAG  # type: ignore[import-not-found]
from airflow.operators.empty import EmptyOperator  # type: ignore[import-not-found]
from airflow.operators.python import PythonOperator  # type: ignore[import-not-found]
from datetime import datetime, timedelta

# Función de Python que simula nuestra validación de calidad (Testing)
def _data_quality_check():
    print("Iniciando validación de calidad de datos...")
    print("✅ Sin valores nulos críticos detectados.")
    print("✅ Integridad transaccional confirmada (The Dzib Standard).")
    return "Data Quality Passed"

# Argumentos base para garantizar resiliencia
default_args = {
    'owner': 'Alberto Dzib',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

# Definición del DAG
with DAG(
    dag_id='p6_enterprise_etl_pipeline',
    default_args=default_args,
    description='Pipeline End-to-End con validación de calidad de datos',
    schedule_interval='@daily',
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=['portfolio', 'etl', 'data-quality'],
) as dag:

    # 1. Nodos de nuestro pipeline
    start_task = EmptyOperator(task_id='inicio_pipeline')

    extract_task = EmptyOperator(task_id='extraccion_masiva_datos')

    quality_check_task = PythonOperator(
        task_id='validacion_calidad_datos',
        python_callable=_data_quality_check
    )

    load_task = EmptyOperator(task_id='carga_segura_datawarehouse')

    end_task = EmptyOperator(task_id='fin_pipeline')

    # 2. Orquestación y dependencias (El flujo direccional)
    start_task >> extract_task >> quality_check_task >> load_task >> end_task
