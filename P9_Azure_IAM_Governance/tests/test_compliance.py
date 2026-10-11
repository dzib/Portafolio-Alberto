from pathlib import Path

def test_p1_exists():

    assert Path(
        "P1_Inventario"
    ).exists()

def test_p2_exists():

    assert Path(
        "P2_Escolar"
    ).exists()
