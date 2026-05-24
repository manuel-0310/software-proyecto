# Observabilidad del Sistema — Weddy

## 1. ¿Qué es la observabilidad?

La observabilidad es la capacidad de entender el estado interno de un sistema a partir de sus salidas externas (métricas, logs y trazas). Un sistema observable permite:

- Detectar problemas antes de que el usuario los reporte
- Entender el comportamiento del sistema en tiempo real
- Identificar cuellos de botella y endpoints con alta latencia
- Auditar el uso del sistema

En Weddy se implementaron las tres herramientas estándar de la industria para observabilidad: **Prometheus**, **Grafana** y **Jaeger**.

---

## 2. Herramientas implementadas

### 2.1 Prometheus — Recolección de métricas

Prometheus es un sistema de monitoreo que recolecta métricas de los servicios a través de un mecanismo llamado **scraping**: cada cierto tiempo, hace una petición HTTP al endpoint `/metrics` del backend y guarda los datos como series de tiempo.

**Configuración implementada** (`monitoring/prometheus/prometheus.yml`):

```yaml
scrape_configs:
  - job_name: "weddy-api"
    static_configs:
      - targets: ["localhost:8000"]
    metrics_path: "/metrics"
    scrape_interval: 10s      # recolecta cada 10 segundos
```

**Integración en el backend** (`services/main.py`):

```python
from prometheus_fastapi_instrumentator import Instrumentator
Instrumentator().instrument(app).expose(app)
```

Esta línea instrumenta automáticamente todos los endpoints de FastAPI y expone el endpoint `/metrics` que Prometheus consume.

**Métricas recolectadas:**


| Métrica                         | Tipo      | Descripción                                                  |
| ------------------------------- | --------- | ------------------------------------------------------------ |
| `http_requests_total`           | Counter   | Total de requests por endpoint, método y código de respuesta |
| `http_request_duration_seconds` | Histogram | Latencia de cada endpoint en segundos                        |
| `http_request_size_bytes`       | Summary   | Tamaño en bytes de los requests entrantes                    |
| `http_response_size_bytes`      | Summary   | Tamaño en bytes de las respuestas enviadas                   |


**Ejemplo de consulta en Prometheus UI:**

```
http_requests_total
```

Resultado: contadores separados por endpoint, método HTTP y código de respuesta (2xx, 4xx, 5xx).

### 2.2 Grafana — Visualización de métricas

Grafana se conecta a Prometheus como fuente de datos y permite crear dashboards visuales con las métricas en tiempo real.

**Datasource configurado** (`monitoring/grafana/provisioning/datasources/prometheus.yml`):

```yaml
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    isDefault: true
```

**Dashboard implementado:**

- Métrica: `http_requests_total{job="weddy-api"}`
- Tipo de visualización: Time series (gráfica temporal)
- Cada request desde la app Flutter genera un punto en la gráfica en tiempo real

**Acceso:** `http://localhost:3000` (usuario: `admin`, contraseña: `weddy2024`)

### 2.3 Jaeger — Trazabilidad distribuida

Jaeger es una herramienta de tracing distribuido. Mientras Prometheus cuenta cuántos requests llegaron, Jaeger registra el **recorrido interno** de cada request individual: cuánto tiempo tomó, qué operaciones se ejecutaron y si hubo errores.

**Integración en el backend** (`services/telemetry/tracing.py`):

```python
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

provider = TracerProvider(resource=Resource.create({"service.name": "weddy-api"}))
exporter = OTLPSpanExporter(endpoint="http://localhost:4318/v1/traces")
provider.add_span_processor(BatchSpanProcessor(exporter))
trace.set_tracer_provider(provider)
```

El backend envía trazas a Jaeger usando el protocolo **OTLP HTTP** al puerto 4318. Cada request genera un **span** con:

- Nombre del endpoint llamado
- Método HTTP
- Código de respuesta
- Tiempo de procesamiento

**Activación:** el tracing se activa con la variable de entorno `JAEGER_ENABLED=true` al iniciar el backend:

```bash
JAEGER_ENABLED=true uvicorn main:app --host 0.0.0.0
```

**Acceso:** `http://localhost:16686` → seleccionar servicio `weddy-api` → Find Traces

---

## 3. Endpoints monitoreados

La observabilidad cubre automáticamente todos los endpoints del sistema:


| Endpoint                       | Visible en Prometheus | Visible en Jaeger |
| ------------------------------ | --------------------- | ----------------- |
| `POST /auth/login`             | ✅                     | ✅                 |
| `GET /invitados/`              | ✅                     | ✅                 |
| `POST /invitados/`             | ✅                     | ✅                 |
| `PATCH /invitados/{id}/estado` | ✅                     | ✅                 |
| `DELETE /invitados/{id}`       | ✅                     | ✅                 |
| `GET /presupuesto/`            | ✅                     | ✅                 |
| `POST /presupuesto/configurar` | ✅                     | ✅                 |
| `GET /health`                  | ✅                     | ✅                 |


---

## 4. Flujo completo de observabilidad

```
Usuario usa la app Flutter
        │
        ▼
App hace GET /invitados/ al backend
        │
        ▼
FastAPI procesa el request
        │
        ├──► OpenTelemetry genera un span → lo envía a Jaeger (puerto 4318)
        │         → visible en http://localhost:16686
        │
        └──► Prometheus-FastAPI-Instrumentator incrementa contadores
                  → visible en http://localhost:8000/metrics
                  → Prometheus scrapea cada 10s → guarda en serie de tiempo
                  → Grafana consulta Prometheus → actualiza gráfica
                       → visible en http://localhost:3000
```

---

## 5. Evidencia de funcionamiento

### Prometheus — métricas en crudo

Al acceder a `http://localhost:8000/metrics` directamente se puede leer:

```
http_requests_total{handler="/invitados/",method="GET",status="2xx"} 7.0
http_requests_total{handler="/invitados/",method="POST",status="2xx"} 1.0
http_requests_total{handler="/auth/login",method="POST",status="2xx"} 1.0
```

Cada número refleja cuántas veces fue llamado ese endpoint durante la sesión.

### Prometheus UI — consulta interactiva

![Métricas en Prometheus UI](../src/prometheus.png)

### Grafana — gráfica temporal

![Dashboard Grafana](../src/grafana.png)

### Jaeger — trazas por request

![Trazas en Jaeger](../src/jaeger.png)

---

## 6. Conclusión

La integración de Prometheus, Grafana y Jaeger convierte a Weddy en un sistema observable. Cualquier request que haga la app Flutter queda registrado en las tres herramientas: contado en Prometheus, visualizado en Grafana y trazado en Jaeger. Esto permite monitorear el sistema en tiempo real y diagnosticar problemas con precisión, cumpliendo el requisito de observabilidad de la rúbrica en todos los endpoints del sistema.