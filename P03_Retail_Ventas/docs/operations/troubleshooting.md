# Guía de Resolución de Problemas (Troubleshooting) - P3 Retail

## 1. Errores de Conexión ODBC / SQLAlchemy

- **Síntoma:** Falla en la ejecución del script `02_CargaSQL.py`
  indicando que no se encuentra el controlador.
- **Causa:** El controlador ODBC Driver 17 o 18 no está registrado
  correctamente o la cadena de conexión apunta a una instancia local inválida.
- **Solución:** Verificar la versión instalada del controlador ODBC en el
  sistema operativo y actualizar la cadena de conexión en el script de
  Python utilizando `mssql+pyodbc://`.

## 2. Violación de Unique Key en Carga SQL

- **Síntoma:** El motor de SQL Server rechaza lotes de inserción debido
  a colisiones de claves únicas en catálogos.
- **Causa:** Variaciones de precios o descripciones en origen durante la
  generación sintética con Faker.
- **Solución:** Asegurar que los scripts DDL/DML utilicen funciones de
  agregación como `MAX()` y agrupamiento `GROUP BY` para mantener la
  integridad de unicidad antes de persistir en producción.

## 3. Cuellos de Botella por I/O en Disco

- **Síntoma:** Tiempos de ingesta elevados al procesar los 50,000
  registros.
- **Causa:** Saturación temporal del almacenamiento local durante
  escrituras masivas concurrentes.
- **Solución:** Validar la optimización de caché de escritura en el
  volumen lógico y asegurar que el parámetro `fast_executemany=True`
  esté activo en SQLAlchemy.
