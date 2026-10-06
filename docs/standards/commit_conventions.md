# 📝 Convenciones de Commits (Conventional Commits)

Utilizamos un formato estructurado para los mensajes de commit,
facilitando la lectura del historial y la generación automática de
changelogs.

## Estructura

`<tipo>(<ámbito>): <descripción_breve>`

## Tipos Permitidos

- `feat`: Introducción de una nueva funcionalidad o módulo.
- `fix`: Corrección de errores o fallos en código o pipelines.
- `refactor`: Reestructuración de código sin alterar su
  comportamiento externo.
- `docs`: Adición o actualización de documentación (Markdown).
- `test`: Creación o modificación de pruebas unitarias (`pytest`).
- `chore`: Tareas de mantenimiento, configuración de dependencias o
  ajustes de entorno.
