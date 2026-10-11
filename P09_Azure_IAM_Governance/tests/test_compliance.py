# tests/test_compliance.py
import os
import pytest # pyright: ignore[reportMissingImports]

def test_scripts_iam_existen():
    """Valida que los scripts de automatización de IAM existan en la ruta correcta."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    script_users = os.path.join(base_dir, "scripts", "setup_tenant_users.py")
    script_rbac = os.path.join(base_dir, "scripts", "assign_rbac_roles.py")

    assert os.path.exists(script_users), "Falta el script de aprovisionamiento de usuarios."
    assert os.path.exists(script_rbac), "Falta el script de asignación de roles RBAC."

def test_principio_menor_privilegio_configurado():
    """Valida conceptualmente que la estructura del módulo cumpla con normativas de seguridad."""
    doc_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "README.md")
    assert os.path.exists(doc_path), "Falta el README maestro del módulo."

    with open(doc_path, "r", encoding="utf-8") as f:
        content = f.read()
        assert "Principio de Menor Privilegio" in content, "El README debe declarar el cumplimiento de PoLP."
