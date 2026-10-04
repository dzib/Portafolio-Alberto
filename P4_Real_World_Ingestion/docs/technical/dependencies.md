# 🔄 Flujo de Datos - P4: Real-World Ingestion

El pipeline de datos sigue un flujo estructurado de 5 fases principales:

1. **Extracción en Origen:** Lectura del dataset masivo de Kaggle
   (DataCo Global Supply Chain) mediante script de Python.
2. **Ingesta a Staging:** Carga masiva optimizada con `fast_executemany` hacia
   la tabla `Staging.Kaggle_SupplyChain_Raw`.
3. **Orquestación y Transacciones:** Procesamiento atómico mediante bloques
   `BEGIN TRY...CATCH` controlados por T-SQL.
4. **Limpieza y Normalización:** Transformación y manejo de anomalías usando
   T-SQL dinámico (`sp_executesql`).
5. **Consumo Analítico:** Exposición de vistas de eficiencia logística hacia
   el entorno de PyGWalker.

## 📦 Dependencias del Sistema - P4: Supply Chain

El proyecto depende de las siguientes librerías de Python y componentes de infraestructura:

- **`pandas>=2.0.0`**: Manipulación y análisis de estructuras de datos en memoria.
- **`sqlalchemy>=2.0.0`**: Abstracción de bases de datos relacionales y gestión
 de motores de conexión.
- **`pyodbc>=4.0.39`**: Conector ODBC de bajo nivel para SQL Server.
- **`python-dotenv>=1.0.0`**: Gestión segura de variables de entorno y
 credenciales locales.
- **`pygwalker>=0.1.0`**: Interfaz de visualización interactiva tipo Tableau
 para análisis exploratorio.
