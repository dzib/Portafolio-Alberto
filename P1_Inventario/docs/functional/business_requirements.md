
# Requerimientos de Negocio - Sistema de Control de Inventarios (P1)

## 1. Visión General

El proyecto P1 busca estandarizar la captura, procesamiento y
consumo de datos operativos de inventario y ventas en mostrador
(POS), garantizando la integridad referencial y eliminando
 discrepancias causadas por ingresos manuales o sistemas legacy.

## 2. Requerimientos Funcionales

- **RF-01 (Integridad Transaccional):** El sistema debe impedir la
  inserción de registros huérfanos mediante claves primarias y
  foráneas (`PK`/`FK`) estrictas.
- **RF-02 (Remediación de Datos Sucios):** El pipeline ETL debe ser
  capaz de descomponer campos compuestos y estandarizar la
  capitalización (*Title Case*) de forma automatizada.
- **RF-03 (Visibilidad Operativa):** Los tomadores de decisiones
  deben consumir vistas analíticas unificadas (*Omnicanal*)
  directamente en Excel mediante un puente ODBC.
- **RF-04 (Alertas Logísticas):** El sistema debe clasificar de
  manera automática los niveles de stock para identificar productos
  con riesgo de desabastecimiento.

