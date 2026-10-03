# Requerimientos de Negocio - Pipeline Híbrido P3 Retail

## 1. Visión General

El proyecto P3 simula operaciones de comercio minorista (*Retail*), combinando
la agilidad de Python para la generación sintética y analítica de datos con la
robustez transaccional de SQL Server 2025.

## 2. Requerimientos Funcionales

- **RF-01 (Generación Sintética Reproducible):** Creación de 50,000+ registros
	de transacciones comerciales utilizando semillas estables en la librería
	`Faker`.
- **RF-02 (Ingesta Híbrida de Alta Velocidad):** Carga masiva optimizada hacia
	bases de datos relacionales sin degradación de rendimiento.
- **RF-03 (Analítica Sub-Segundo):** Generación de reportes ejecutivos (Top
	Vendedores, Preferencias de Pago) en tiempos menores a un segundo (`<0.6s`).
- **RF-04 (Integridad y Consistencia de Datos):** Validación de tipos de datos
	y consistencia referencial entre el DataFrame de pandas y el esquema DDL de
	SQL Server.

## 3. Objetivo

Analizar 50,000 transacciones retail simuladas.

## 4. Stakeholders

- Gerencia Comercial
- Operaciones
- Finanzas

## 5. Necesidades

- Ventas
- Margen
- Rotación
- Ticket promedio

## 6. Alcance

El proyecto analiza ventas retail simuladas para identificar tendencias
comerciales, desempeño por producto y métricas clave para la toma de
decisiones.

## 7. Criterios de éxito

- Dashboard funcional
- KPIs calculados correctamente
- Dataset validado
