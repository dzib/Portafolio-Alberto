# src/generate_multi_source.py
from datetime import datetime, timedelta
import csv
import json
import os
import random

def generar_fuentes_heterogeneas():
    os.makedirs("data/raw", exist_ok=True)
    random.seed(42)

    # 1. Fuente E-commerce (CSV)
    n_ecom = 1000
    ventas_ecom = []
    productos = ["Software ERP", "Licencia CRM", "Consultoría Cloud"]
    for _ in range(n_ecom):
        ventas_ecom.append({
            "fecha": datetime(2025, 1, 1) + timedelta(days=random.randrange(365)),
            "canal_origen": "E-commerce Web",
            "cliente": f"Cliente_Web_{random.randrange(100, 300)}",
            "producto": random.choice(productos),
            "monto": round(random.expovariate(1 / 1200) + 150, 2)
        })

    # Inyectar nulos sin depender de pandas.
    for indice in random.sample(range(n_ecom), 5):
        ventas_ecom[indice]["monto"] = ""

    with open("data/raw/ventas_ecommerce.csv", "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=ventas_ecom[0].keys())
        writer.writeheader()
        writer.writerows(ventas_ecom)

    # 2. Fuente Sucursales Físicas (JSON semiestructurado)
    n_pos = 500
    datos_pos = []
    for _ in range(n_pos):
        datos_pos.append({
            "fecha_transaccion": (datetime(2025, 1, 1) + timedelta(days=random.randrange(365))).strftime("%Y-%m-%d"),
            "canal_origen": "Tienda Física POS",
            "id_cliente": f"Cliente_POS_{random.randrange(400, 600)}",
            "articulo": random.choice(["Soporte SLA", "Migración Database", "Hardware Setup"]),
            "total_venta": round(random.expovariate(1 / 2000) + 300, 2)
        })
    with open("data/raw/transacciones_pos.json", "w", encoding="utf-8") as f:
        json.dump(datos_pos, f, indent=4, ensure_ascii=False)

    print("✅ Fuentes heterogéneas (CSV y JSON) generadas exitosamente en data/raw/")

if __name__ == "__main__":
    generar_fuentes_heterogeneas()
