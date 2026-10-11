# src/agent.py
import ollama
from src.config import OLLAMA_MODEL

def consultar_agente_analista(kpis: dict):
    """Envía los KPIs calculados a Ollama para generar un reporte ejecutivo inteligente."""

    system_prompt = """
    Eres un Director de Analytics y Senior Data Analyst con amplia experiencia corporativa.
    Tu objetivo es analizar los KPIs financieros y proporcionar un reporte ejecutivo claro en español.
    Estructura tu respuesta en:
    1. Resumen Ejecutivo
    2. Hallazgos Principales
    3. Riesgos u Oportunidades
    4. Recomendaciones Estratégicas
    """

    prompt = f"""
    Analiza los siguientes KPIs extraídos del sistema:
    - Ventas Totales: ${kpis['ventas_totales']:,.2f}
    - Ticket Promedio: ${kpis['ticket_promedio']:,.2f}
    - Clientes Únicos: {kpis['clientes_unicos']}

    Resumen Estadístico del Dataset:
    {kpis['resumen_estadistico']}
    """

    try:
        respuesta = ollama.chat(
            model=OLLAMA_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        return respuesta["message"]["content"]
    except Exception as e:
        return f"Error al conectar con Ollama: {str(e)}. Asegúrate de que el servicio local esté activo."
