# src/main.py
from src.etl import cargar_datos
from src.analytics import calcular_kpis
from src.agent import consultar_agente_analista
from src.report_generator import guardar_reporte_ejecutivo

if __name__ == "__main__":
    print("🚀 [P8] Iniciando Pipeline de IA y Analítica Avanzada...")

    df = cargar_datos()
    print("✅ Ingesta y validación ETL completada.")

    kpis = calcular_kpis(df)
    print("📊 KPIs y estadísticos calculados con éxito.")

    print("🤖 Consultando al Agente Local (Ollama - Llama 3.2)...")
    analisis_ia = consultar_agente_analista(kpis)

    ruta_salida = guardar_reporte_ejecutivo(analisis_ia)
    print(f"\n📁 Reporte gerencial exportado exitosamente en: {ruta_salida}")
    print("\n" + "="*50 + "\nPROCESO FINALIZADO CON ÉXITO\n" + "="*50)
