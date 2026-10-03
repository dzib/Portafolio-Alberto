# Data Dictionary

## Objetivo

Documentar los activos de datos utilizados por el sistema
académico y garantizar una comprensión uniforme de la
información a nivel funcional, operativo y analítico.

---

## Esquema Catalogos

Contiene entidades maestras utilizadas por el sistema.

---

## Resumen Ejecutivo

El sistema académico se divide en dos dominios principales:

1. **Catálogos**: Entidades maestras que definen la estructura del sistema.
2. **Operaciones**: Entidades transaccionales que representan las
        actividades del sistema.


### Catalogos

Contiene entidades maestras utilizadas por la institución.

- Departamentos
- Carreras
- Profesores
- Alumnos

### Operaciones

Contiene actividades académicas transaccionales generadas durante el
ciclo de vida de los estudiantes.

- Materias
- Inscripciones
- Calificaciones
- Asistencias

---

## Catalogos.Departamentos

Descripción:

Representa las facultades o unidades académicas.

| Campo | Tipo | Descripción |
|---------|---------|---------|
| DeptoID | INT | Identificador único |
| Nombre | VARCHAR(100) | Nombre del departamento |
| Presupuesto | DECIMAL(12,2) | Presupuesto anual asignado |
| IsActive | BIT | Estado lógico |

---

## Catalogos.Carreras

Descripción:

Programas académicos pertenecientes a un departamento.

| Campo | Tipo | Descripción |
|---------|---------|---------|
| CarreraID | INT | Identificador de carrera |
| DeptoID | INT | Departamento asociado |
| Nombre | VARCHAR(100) | Nombre de la carrera |
| IsActive | BIT | Estado lógico |

---

## Catalogos.Profesores

Descripción:

Plantilla docente institucional.

| Campo | Tipo | Descripción |
|---------|---------|---------|
| ProfesorID | INT | Identificador docente |
| Nombre | VARCHAR(150) | Nombre completo |
| Email | VARCHAR(200) | Correo institucional |
| DeptoID | INT | Facultad asociada |
| Sexo | CHAR(1) | Sexo registrado |
| MetaData_ETL | VARCHAR(MAX) | Metadata de generación |
| IsActive | BIT | Estado lógico |

---

## Catalogos.Alumnos

Descripción:

Estudiantes registrados en la institución.

| Campo | Tipo | Descripción |
|---------|---------|---------|
| AlumnoID | INT | Identificador |
| Nombre | VARCHAR(150) | Nombre completo |
| CarreraID | INT | Carrera asociada |
| DeptoID | INT | Facultad asociada |
| Email | VARCHAR(200) | Correo académico |
| FechaNacimiento | DATE | Fecha de nacimiento |
| Sexo | CHAR(1) | Sexo registrado |
| MetaData_ETL | VARCHAR(MAX) | Metadata legacy |

---

## Esquema Operaciones

Contiene procesos transaccionales.

---

## Operaciones.Materias

Descripción:

Oferta académica disponible por ciclo.

| Campo | Tipo |
|---------|---------|
| MateriaID | INT |
| Nombre | VARCHAR(200) |
| ProfesorID | INT |
| CursoID | INT |
| CicloEscolar | VARCHAR(20) |
| Grupo | VARCHAR(5) |

---

## Operaciones.Inscripciones

Descripción:

Relación entre alumnos y materias.

| Campo | Tipo |
|---------|---------|
| InscripcionID | INT |
| AlumnoID | INT |
| MateriaID | INT |
| NotaFinal | DECIMAL(5,2) |

---

## Operaciones.Calificaciones

Descripción:

Calificaciones parciales asociadas a una inscripción.

| Campo | Tipo |
|---------|---------|
| CalificacionID | INT |
| InscripcionID | INT |
| ParcialNumero | INT |
| Nota | DECIMAL(5,2) |
| MetaData_ETL | VARCHAR(MAX) |

---

## Operaciones.Asistencias

Descripción:

Registro histórico de asistencia estudiantil.

| Campo | Tipo |
|---------|---------|
| AsistenciaID | INT |

## Diagrama de Dominio

Departamentos
│
└── Carreras
        │
        └── Alumnos

Profesores
│
└── Materias
        │
        └── Inscripciones
                │
                ├── Calificaciones
                └── Asistencias
