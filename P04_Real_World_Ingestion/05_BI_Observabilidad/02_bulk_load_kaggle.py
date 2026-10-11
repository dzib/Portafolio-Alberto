import pandas as pd

def validate_schema_coherence(conn, df, target_schema, target_table):
    """Verifica que las columnas del CSV hagan match exacto con SQL Server."""

    query = f"""
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{target_schema}'
      AND TABLE_NAME = '{target_table}'
    ORDER BY ORDINAL_POSITION;
    """

    # 1. Leer el Single Source of Truth físico (SQL Server)
    sql_columns = pd.read_sql(query, conn)['COLUMN_NAME'].tolist()

    # 2. Extraer columnas del DataFrame en Staging
    csv_columns = df.columns.tolist()

    # 3. Detectar deltas
    missing_in_sql = [col for col in csv_columns if col not in sql_columns]
    missing_in_csv = [col for col in sql_columns if col not in csv_columns]

    if missing_in_sql or missing_in_csv:
        raise ValueError(f"""
        ❌ Incoherencia de esquema detectada que rompería el pipeline:
        Columnas que sobran en el CSV: {missing_in_sql}
        Columnas que faltan en el CSV: {missing_in_csv}
        """)

    print(f"\n✅ Coherencia validada: {len(sql_columns)} columnas mapeadas perfectamente.")
