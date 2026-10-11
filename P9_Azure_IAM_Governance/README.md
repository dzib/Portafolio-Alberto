# P9: Azure IAM & Governance (Identity and Access Management)

## 🎯 Propósito del Módulo

Este módulo implementa las mejores prácticas de seguridad, control de
accesos basado en roles (**RBAC**) y gobernanza de identidades en entornos
de Azure (**Microsoft Entra ID**), asegurando el cumplimiento del
*Principio de Menor Privilegio (PoLP)* para plataformas de datos
corporativas.

---

## 🏗️ Arquitectura y Componentes

1. **Gestión de Identidades (Entra ID):** Automatización lógica para
   la creación de usuarios, gestión de invitados (*Guest Users*) y
   agrupación mediante Grupos de Seguridad.
2. **Control de Acceso (Azure RBAC):** Asignación de roles granulares
   (`Reader`, `Contributor`, `Storage Blob Data Contributor`) a nivel de
   recursos de datos.
3. **Identidades de Servicio (Service Principals):** Configuración
   segura para autenticación de pipelines ETL sin credenciales
   hardcodeadas.

```text
P9_Azure_IAM_Governance/
│
├── .env.example                 # Variables para Azure CLI / SDK
├── README.md                    # Documentación y despliegue
├── requirements.txt             # Dependencias (azure-identity,
│                                azure-mgmt-authorization, etc.)
│
├── docs/                        # Gobierno y arquitectura
│   ├── decisions/               # ADR-001: Menor privilegio (PoLP)
│   ├── functional/              # Seguridad y segregación de funciones
│   └── technical/               # Flujos de identidades
│
├── scripts/                     # Automatización Python / CLI / PowerShell
│   ├── setup_tenant_users.py    # Simulación o gestión de creación
│   │                            # de usuarios / grupos
│   └── assign_rbac_roles.py     # Automatización de asignación
│                                # de roles (Reader, Contributor, Owner)
│
└── tests/                       # Pruebas unitarias y de cumplimiento
    └── test_iam_compliance.py   # Validación de políticas de seguridad
```

---

## 🔑 Conceptos Clave que Implementaremos en Código

1. Microsoft Entra ID (Tenant & Directory):

Creación y gestión lógica de usuarios miembros e invitados
(Guest Users).

Creación de Grupos de Seguridad y Grupos de Microsoft 365 para control
de acceso basado en grupos. Es una buena práctica para no asignar
permisos usuario por usuario.

1. Control de Acceso Basado en Roles (Azure RBAC):

Asignación de roles nativos (Owner, Contributor, Reader y
Storage Blob Data Contributor) a nivel de suscripción, grupo de
recursos o recurso específico (como un Data Lake o SQL Server).

Uso del Principio de Menor Privilegio (PoLP): los usuarios y las
aplicaciones de datos solo deben tener los permisos estrictamente
necesarios para operar.

1. Identidades Administradas y Service Principals (App Registrations):

Configuración de credenciales y tokens para que tus pipelines ETL
(como los de Python o Azure Data Factory) se conecten de forma segura
a Azure sin almacenar contraseñas en texto plano.

---

## 🛠️ Estructura de Scripts

- `scripts/setup_tenant_users.py`: Simulación de aprovisionamiento de
  usuarios y grupos corporativos.
- `scripts/assign_rbac_roles.py`: Automatización de asignación de roles y
  políticas de seguridad.
- `tests/test_compliance.py`: Pruebas automatizadas de validación de
  esquemas y cumplimiento de accesos.

---

## 🚀 Ejecución y Pruebas

Para validar la correcta configuración y las pruebas unitarias del módulo,
 ejecuta en tu terminal:

```PowerShell
pytest P9_Azure_IAM_Governance/tests/test_compliance.py -v
```
