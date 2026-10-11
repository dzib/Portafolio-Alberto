# ADR-001: Adopción del Principio de Menor Privilegio (PoLP) en Accesos de Datos

## 📌 Contexto y Estado

En las plataformas de datos corporativas, la sobreasignación
de permisos (ej. otorgar roles de `Contributor` o `Owner`
de forma generalizada) expone a la organización a brechas
de seguridad y fugas de información.

## 🛠️ Decisión

Se implementa formalmente el **Principio de Menor Privilegio
(PoLP)** mediante Azure RBAC granular. Ningún usuario o
pipeline de datos tendrá más privilegios de los
estrictamente necesarios para ejecutar su tarea específica.

## 📊 Consecuencias

- Mayor control de auditoría y cumplimiento normativo.
- Reducción drástica del radio de impacto ante posibles compromisos de credenciales.
