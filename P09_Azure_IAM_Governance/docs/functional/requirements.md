# Requisitos Funcionales: Seguridad y Segregación de Funciones (SoD)

1. **Aprovisionamiento Controlado:** Todo alta de usuario en Microsoft
 Entra ID debe estar asociado a un grupo de seguridad predefinido
 (`GRP-Data-Engineers`, `GRP-Auditors`).
2. **Segregación de Funciones (SoD):** Los roles operativos de ingeniería
 no deben solaparse con los roles de auditoría de cumplimiento externo.
3. **Cero Credenciales en Código:** Queda estrictamente prohibido el uso de
 contraseñas en texto plano o claves estáticas hardcodeadas en scripts de
 Python o pipelines ETL.
