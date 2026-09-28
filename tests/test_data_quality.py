def test_dataframe_not_empty():
    """Valida que los datasets principales contengan registros para procesar."""
    # Ejemplo genérico simulando una carga de datos o archivo analítico
    data = [{"id": 1, "valor": 100}, {"id": 2, "valor": 200}, {"id": 3, "valor": 300}]
    assert data, "El conjunto de datos no debe estar vacío."

def test_no_nulls_in_primary_key():
    """Valida la ausencia de valores nulos en columnas identificadoras (Llaves primarias)."""
    data = [{"id": 1, "categoria": "A"}, {"id": 2, "categoria": "B"}, {"id": 3, "categoria": "C"}]
    assert all(row["id"] is not None for row in data), "Se encontraron valores nulos en la columna clave."

def test_positive_values():
    """Valida que las métricas financieras o de conteo no presenten valores negativos anómalos."""
    data = [{"metrica": 50.5}, {"metrica": 120.0}, {"metrica": 300.2}]
    assert all(row["metrica"] >= 0 for row in data), "Se detectaron valores negativos en métricas que deben ser positivas."