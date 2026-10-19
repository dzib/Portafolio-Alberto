<!-- markdownlint-disable MD013 MD007 MD051 -->

# Módulo P10: Secure On-Premises Remote Desktop Infrastructure (RustDesk Server OSS)

[🏠 Volver al Inicio](../README.md) | [📚 Ver Roadmap](../ROADMAP.md)

---

## 📋 Índice de Navegación Rápida

- [1. Resumen Ejecutivo (Método STAR)](#-1-resumen-ejecutivo-método-star)
- [2. Arquitectura de la Solución](#-2-arquitectura-de-la-solución)
- [3. Configuración de Infraestructura](#-3-configuración-de-infraestructura)
- [4. Guía de Despliegue y Aprovisionamiento](#-4-guía-de-despliegue-y-aprovisionamiento)
- [5. Configuración de Clientes](#-5-configuración-de-clientes)

---

## 🎯 1. Resumen Ejecutivo (Método STAR)

* **Situación:** Las organizaciones y entornos de desarrollo modernos requieren capacidades de soporte y control remoto que garanticen la soberanía y privacidad de los datos, evitando la dependencia absoluta de pasarelas de terceros o servicios cloud externos.
* **Tarea:** Diseñar, desplegar y documentar una infraestructura de escritorio remoto auto-hospedada (*Self-Hosted*) utilizando código abierto (*Open Source*), garantizando el aislamiento de servicios mediante microcontenedores y cifrado de extremo a extremo.
* **Acción:** Implementación de un clúster local de RustDesk Server OSS (`hbbs` y `hbbr`) orquestado con Docker Compose en un entorno Windows/WSL, gestionando volúmenes persistentes y control de puertos de red.
* **Resultado:** Un gateway de acceso remoto seguro, independiente y listo para producción, con persistencia de datos y llaves criptográficas validadas.

---

## 🏗️ 2. Arquitectura de la Solución

El despliegue separa responsabilidades en dos microservicios complementarios gestionados por Docker:

1. **`hbbs` (RustDesk ID / Rendezvous Server):** Gestiona la libreta de direcciones, coordinación de conexiones e intercambio de claves de cifrado (`ed25519`).
2. **`hbbr` (RustDesk Relay Server):** Actúa como pasarela de retransmisión de tráfico cuando una conexión directa punto a punto (P2P / NAT) no es posible.

```text
+---------------------------------------------------------------+
|                    Docker Host (Windows / WSL)                |
|                                                               |
|  +--------------------+             +----------------------+  |
|  |     Container      |             |      Container       |  |
|  |       hbbs         | <---------> |         hbbr         |  |
|  |  (ID & Rendezvous) |             |    (Relay Gateway)   |  |
|  +--------------------+             +----------------------+  |
|           |                                     |             |
|           +-----------------+-------------------+             |
|                             |                                 |
|                    Volume Persistence                         |
|                       (./data:/root)                          |
+---------------------------------------------------------------+
```

---

## ⚙️ 3. Configuración de Infraestructura (`docker-compose.yml`)

```yaml
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    restart: unless-stopped
  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    restart: unless-stopped
```

---

## 🚀 4. Guía de Despliegue y Aprovisionamiento

1. Ubicarse en el directorio del módulo:

```PowerShell
cd P10_Secure_OnPrem_Remote_Desktop_Infrastructure
```

1. Iniciar los servicios en segundo plano:

```PowerShell
docker compose up -d
```

1. Verificar el estado de los contenedores:

```PowerShell
docker ps
```

1. Obtener la Clave Pública de Cifrado (Key):


```PowerShell
docker logs hbbs
```

> **Nota:** Busca en la salida de la consola la línea que contiene la clave pública (Key: ...) generada automáticamente en el par de claves ed25519.

---

## 🔐 5. Configuración de Clientes

En las aplicaciones cliente de RustDesk que desearas conectar a este servidor propio:

* Ir a Configuración -> Red.

* Asignar la IP del servidor en ID Server y Relay Server.

* Ingresar la Key pública obtenida en los logs del contenedor hbbs.

---

## Evidencia de Rendimiento y Arquitectura Atómica

![Consumo Ligero del Servidor](assets/images/servidorDockerLigero-benchmark.png)
![Estructura de Archivos Persistente](assets/images/estructuraArchivosAisladoDocker-desktop.png)

---

## 🛠️ 6. Evolución Arquitectónica y Troubleshooting

A lo largo del despliegue, la infraestructura experimentó iteraciones críticas para resolver cuellos de botella de red y limitaciones de hardware, simulando escenarios reales de migración On-Premise:

### Desafío Topológico: Segmentación de Red (Doble Subred)

* **Problema Identificado:** Inicialmente, el entorno local estaba segmentado en dos subredes físicas/lógicas distintas. Esto bloqueaba el tráfico de descubrimiento automático (broadcast) de los clientes de RustDesk y forzaba saltos de enrutamiento innecesarios, lo que impedía establecer el túnel P2P de manera directa y fluida.
* **Solución y Decisión Arquitectónica:** Se reestructuró la topología física introduciendo un **Switch de red** dedicado. Esto permitió aplanar la arquitectura hacia una **única capa de red (Single Layer 2 Broadcast Domain)**, unificando las IPs en el mismo segmento (`192.168.68.x`).
* **Impacto:** Eliminación del doble NAT local, garantizando visibilidad directa, cero latencia de enrutamiento entre el contenedor y los clientes, y simplificando las reglas del Firewall de Windows/Bitdefender.

### Cuellos de Botella de Hardware y Next Steps

* **Limitante Actual:** Se detectó que el hardware de la Mini PC (Servidor) genera un cuello de botella debido a limitaciones de I/O en el disco de estado sólido y saturación de memoria base, afectando el performance general del host cuando los contenedores están bajo carga.
* **Next Steps (Plan de Optimización Activo):**
  1. **Purga y Desfragmentación (I/O Optimization):** Eliminación agresiva de archivos residuales del sistema operativo (como directorios `Windows.old`) utilizando herramientas de liberación profunda y mapeo con `WizTree` para reducir la latencia de lectura/escritura.
  2. **Tuning de Memoria Virtual:** Configuración estática del archivo de paginación (`pagefile.sys`) para evitar micro-congelamientos por redimensionamiento dinámico del disco.
  3. **Escalabilidad Física:** Proyección de actualización de hardware (RAM y expansión de SSD dedicado) para aislar la carga de los contenedores Docker de los procesos críticos del sistema operativo.
  4. **Monitoreo Continuo:** Implementación de métricas de rendimiento con `Prometheus` y `Grafana` para alertas tempranas sobre saturación de recursos y cuellos de botella en tiempo real.


---

## Author

Alberto Dzib

LinkedIn: [Alberto Dzib](https://linkedin.com/in/alberto-dzib)

Portfolio: [Portafolio-Alberto](https://github.com/dzib/Portafolio-Alberto)

Versión: 1.0.0
