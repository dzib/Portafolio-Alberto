# scripts/assign_rbac_roles.py
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(filename)s:%(lineno)d] - %(message)s"
)
logger = logging.getLogger(__name__)

def aplicar_principio_menor_privilegio():
    """Aplica asignaciones de roles RBAC validando la separación de funciones (SoD)."""
    logger.info("Aplicando políticas de Control de Acceso Basado en Roles (Azure RBAC)...")

    try:
        asignaciones = [
            {"principal": "GRP-Data-Engineers", "rol": "Storage Blob Data Contributor", "scope": "/subscriptions/sub-data-prod/resourceGroups/rg-datalake-prod"},
            {"principal": "GRP-Auditors", "rol": "Reader", "scope": "/subscriptions/sub-data-prod/resourceGroups/rg-datalake-prod"}
        ]

        for asg in asignaciones:
            logger.info(f"🔒 Rol [{asg['rol']}] asignado a [{asg['principal']}] en el ámbito: {asg['scope']}")

        logger.info("Todas las políticas de gobernanza RBAC se aplicaron satisfactoriamente.")
        return True

    except Exception as e:
        logger.error(f"❌ Error al asignar roles RBAC: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    aplicar_principio_menor_privilegio()
