# 🚀 Guía de Despliegue Técnico (Technical Deployment Guide)

Pasos normalizados para la configuración, ejecución y validación del entorno local.

## 📋 Requisitos de Entorno

- Estación de trabajo Windows 11 (Almacenamiento particionado: SO en
  `C:\`, herramientas en `D:\Dev`).
- SQL Server 2025 / SSMS 22.
- Python 3.13 con entorno virtual (`.venv`).


## ⚙️ Pasos de Instalación y Configuración

1. Clonar el repositorio y posicionarse en la rama de trabajo actual:

```bash
   git checkout main
```

2. Inicializar y activar el entorno virtual de Python:

```bash
   python -m venv .venv
   .venv\Scripts\activate
```

3. Validar la conectividad con la base de datos local
   mediante el driver ODBC 17.

## 🧪 Pruebas y Validación

Ejecutar el motor de pruebas unitarias y la auditoría global de enlaces:

```bash
pytest -v
python tools/audit_portfolio.py
```

