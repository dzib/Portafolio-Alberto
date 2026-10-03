# 🚀 Guía de Despliegue (Deployment Guide)

Este documento detalla los pasos operativos para configurar y desplegar
 el entorno de desarrollo y ejecución de los proyectos del portafolio.

## Requisitos Previos

1. **Sistema Operativo:** Windows 11 con partición optimizada
 (SO en C:\, herramientas en D:\Dev).
2. **Base de Datos:** SQL Server 2025 instalado localmente junto con
 SQL Server Management Studio (SSMS 22).
3. **Entorno de Python:** Python 3.13 instalado y configurado con un
 entorno virtual (`.venv`).

## Pasos de Configuración

1. Clonar el repositorio y posicionarse en la rama de trabajo
 correspondiente (`develop` o `feature/*`).
2. Instalar las dependencias de desarrollo y librerías clave
 (`pandas`, `sqlalchemy`, `pyodbc`, `pygwalker`, `pytest`).
3. Verificar la conectividad mediante el driver ODBC 17 para SQL Server.
4. Configurar las variables de entorno necesarias para el funcionamiento del proyecto.

## Ejecución

1. Ejecutar los scripts de inicialización de la base de datos para crear
 esquemas y tablas necesarias.
2. Correr los pipelines de ETL en el orden definido en la documentación
 de procesos, asegurando la integridad de los datos.

### Validación

1. Ejecutar las pruebas unitarias y de integración para validar
 el funcionamiento del sistema.

### Rollback

1. En caso de errores críticos, revertir los cambios aplicando los
 scripts de rollback proporcionados en la carpeta `rollback/`.
