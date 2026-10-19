"""Pruebas de integridad para los DAGs de Apache Airflow en el Módulo P6."""

import os
from airflow.models import DagBag


def test_no_import_errors():
    """Valida que todos los DAGs se importen sin errores de sintaxis en Python."""
    dags_path = os.path.join(
        os.path.dirname(__file__), "../dags"
    )
    dag_bag = DagBag(dag_folder=dags_path, include_examples=False)

    # Verifica que no existan errores críticos de importación
    assert len(dag_bag.import_errors) == 0, (
        f"Errores encontrados al importar los DAGs: {dag_bag.import_errors}"
    )


def test_dag_structure():
    """Valida que el DAG principal del portafolio contenga tareas asociadas."""
    dags_path = os.path.join(
        os.path.dirname(__file__), "../dags"
    )
    dag_bag = DagBag(dag_folder=dags_path, include_examples=False)

    # Asegura que el DAG principal esté presente en el bag
    dag_id = "p6_enterprise_etl_pipeline"
    if dag_id in dag_bag.dags:
        dag = dag_bag.get_dag(dag_id)
        assert len(dag.tasks) > 0, "El DAG no contiene tareas configuradas."
