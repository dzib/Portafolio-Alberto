# Arquitectura serverless de BigQuery

## BigQuery frente a bases de datos relacionales

BigQuery es un almacén de datos serverless. Google administra la
infraestructura, la disponibilidad, el escalado y las actualizaciones, por lo
que el equipo no necesita aprovisionar servidores ni dimensionar clústeres.
El usuario solo define consultas, fuentes de datos y controles de acceso, y
paga principalmente por el almacenamiento y el procesamiento utilizado.

En una base de datos relacional tradicional, el cómputo y el almacenamiento
suelen estar unidos a un servidor o clúster. La organización debe planificar
capacidad, administrar índices, aplicar parches y escalar recursos aunque la
carga sea variable. Este modelo resulta adecuado para transacciones con
latencia predecible, pero puede ser menos flexible para análisis masivos.

## Almacenamiento columnar

BigQuery almacena los datos por columnas en lugar de hacerlo por filas. Las
consultas analíticas normalmente seleccionan pocas columnas de muchas filas,
por lo que este formato evita leer atributos que no participan en el cálculo.
También mejora la compresión porque los valores de una misma columna suelen
tener características similares.

Como resultado, disminuyen las operaciones de entrada y salida y se reduce el
volumen de datos procesado. El particionamiento y el *clustering* pueden
restringir aún más el escaneo, lo que favorece el rendimiento y el control de
costes. Las bases relacionales tradicionales suelen optimizar el acceso a
filas completas y a transacciones puntuales, no a exploraciones analíticas de
gran escala.

## Separación de almacenamiento y cómputo

BigQuery desacopla el almacenamiento persistente de los recursos de cómputo.
Los datos permanecen disponibles mientras el servicio asigna capacidad de
consulta según la demanda. Diferentes cargas pueden consultar el mismo
almacenamiento sin que cada equipo mantenga una copia ni un servidor dedicado.

Esta separación permite escalar consultas independientemente del crecimiento
de los datos, absorber picos de uso y evitar que la capacidad reservada quede
ociosa. En conjunto con el modelo serverless y el almacenamiento columnar,
proporciona una plataforma elástica para analítica financiera, conciliación,
reportes y detección de fraude.
