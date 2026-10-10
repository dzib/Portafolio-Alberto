# tests/test_p8.py
import pandas as pd
import pytest
from src.analytics import calcular_kpis
from src.tools import validar_estructura_df, limpiar_valores_nulos

def test_validar_estructura_df_valida():
    """Prueba que un DataFrame con la estructura correcta pase la validación."""
    df_valido = pd.DataFrame({
        "fecha": ["2026-01-01"],
        "cliente": ["Empresa A"],
        "ventas": [1500.0],
        "producto": ["Software"]
    })
    assert validar_estructura_df(df_valido) is True

def test_validar_estructura_df_invalida():
    """Prueba que un DataFrame incompleto falle la validación."""
    df_invalido = pd.DataFrame({"columna_erronea": [123]})
    assert validar_estructura_df(df_invalido) is False

def test_calcular_kpis():
    """Prueba la precisión en el cálculo de los KPIs financieros."""
    df = pd.DataFrame({
        "fecha": ["2026-01-01", "2026-01-02"],
        "cliente": ["Cliente A", "Cliente B"],
        "ventas": [1000.0, 3000.0],
        "producto": ["Prod 1", "Prod 2"]
    })
    kpis = calcular_kpis(df)

    assert kpis["ventas_totales"] == 4000.0
    assert kpis["ticket_promedio"] == 2000.0
    assert kpis["clientes_unicos"] == 2

def test_limpiar_valores_nulos():
    """Prueba el manejo seguro de nulos en la columna ventas."""
    df = pd.DataFrame({
        "fecha": ["2026-01-01"],
        "cliente": ["Cliente A"],
        "ventas": [None],
        "producto": ["Prod 1"]
    })
    df_limpio = limpiar_valores_nulos(df)
    assert df_limpio["ventas"].iloc[0] == 0.0
