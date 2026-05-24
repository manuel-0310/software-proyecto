# Modelo C4 y Vista 4+1 — Weddy

## 1. Modelo C4

El modelo C4 describe la arquitectura de Weddy en cuatro niveles de abstracción progresiva.

---

### Nivel 1 — Diagrama de Contexto del Sistema

Muestra los actores externos y cómo se relacionan con el sistema.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEMA WEDDY                                │
│                                                                 │
│   ┌─────────────┐    REST/JSON    ┌───────────────────────┐    │
│   │  App Flutter │ ─────────────► │   Weddy API (FastAPI) │    │
│   │  (Cliente)   │ ◄───────────── │   Servicio Proveedor  │    │
│   └─────────────┘                └───────────────────────┘    │
│          │                               │                      │
│    Usuario final                   Prometheus / Grafana         │
│    (pareja / planner)                 / Jaeger / Loki           │
└─────────────────────────────────────────────────────────────────┘

Actores externos:
- Usuario → Usa la app Flutter para gestionar bodas
- Equipo de Ops → Monitorea Grafana, consulta logs en Loki, trazas en Jaeger
```

---

### Nivel 2 — Diagrama de Contenedores

Descompone el sistema en sus contenedores (aplicaciones/servicios desplegables).

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          SISTEMA WEDDY                                   │
│                                                                          │
│  ┌───────────────┐     HTTP REST     ┌────────────────────────────────┐  │
│  │  App Flutter  │ ─────────────────►│         Weddy API              │  │
│  │  Dart/Flutter │ ◄─────────────────│ Python 3.11 + FastAPI          │  │
│  │  [Mobile]     │                   │ Puerto: 8000                   │  │
│  └───────────────┘                   └────────────────┬───────────────┘  │
│                                                        │                  │
│                          ┌─────────────────────────────▼──────────────┐  │
│                          │        Stack de Observabilidad              │  │
│                          │                                            │  │
│                          │  ┌──────────┐  ┌──────────┐  ┌─────────┐  │  │
│                          │  │Prometheus│  │ Grafana  │  │ Jaeger  │  │  │
│                          │  │:9090     │  │  :3000   │  │ :16686  │  │  │
│                          │  └──────────┘  └──────────┘  └─────────┘  │  │
│                          │  ┌──────────┐  ┌──────────┐               │  │
│                          │  │  Loki    │  │Promtail  │               │  │
│                          │  │  :3100   │  │(agente)  │               │  │
│                          │  └──────────┘  └──────────┘               │  │
│                          └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

---

### Nivel 3 — Diagrama de Componentes (Weddy API)

Descompone el contenedor "Weddy API" en sus componentes internos.

```
┌────────────────────────────────────────────────────────────┐
│                       Weddy API                            │
│                                                            │
│  ┌────────────────┐  ┌─────────────────┐  ┌────────────┐  │
│  │  Auth Router   │  │Invitados Router  │  │Presupuesto │  │
│  │  /auth/login   │  │ /invitados/      │  │Router      │  │
│  └───────┬────────┘  └────────┬─────────┘  └─────┬──────┘  │
│          │                    │                    │         │
│  ┌───────▼────────────────────▼────────────────────▼──────┐ │
│  │              Auth Dependencies (JWT)                   │ │
│  │         create_access_token / decode_access_token      │ │
│  └────────────────────────────┬───────────────────────────┘ │
│                               │                              │
│  ┌────────────────────────────▼───────────────────────────┐ │
│  │                   Data Store (in-memory)               │ │
│  │          invitados: Dict[int, Any]                     │ │
│  │          presupuesto: Dict[str, Any]                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────────┐ │
│  │Prometheus  │  │  OpenTelemetry│  │   FastAPI Middleware │ │
│  │Instrumenta.│  │  (Jaeger)    │  │   (CORS)            │ │
│  └────────────┘  └──────────────┘  └─────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

---

### Nivel 4 — Diagrama de Código (Módulo Auth)

Detalle de las clases más relevantes del módulo de autenticación.

```
┌─────────────────┐     usa      ┌─────────────────────┐
│  AuthRouter     │ ───────────► │  create_access_token│
│  POST /login    │              │  (auth/jwt.py)      │
└────────┬────────┘              └─────────────────────┘
         │ valida con
         ▼
┌─────────────────┐     usa      ┌─────────────────────┐
│  bcrypt.checkpw │              │  HTTPBearer         │
│  (password hash)│              │  get_current_user   │
└─────────────────┘              │  (dependencies.py)  │
                                 └──────────┬──────────┘
                                            │ llama
                                            ▼
                                 ┌─────────────────────┐
                                 │  decode_access_token│
                                 │  (auth/jwt.py)      │
                                 └─────────────────────┘
```

---

## 2. Vista 4+1

El modelo 4+1 describe la arquitectura desde cinco perspectivas diferentes.

---

### Vista Lógica — ¿Qué hace el sistema?

Organiza la funcionalidad en módulos lógicos de responsabilidad única.

```
┌─────────────────────────────────────────┐
│           Capa de Presentación           │
│   Flutter UI Screens / Swagger /docs     │
├─────────────────────────────────────────┤
│           Capa de Aplicación             │
│   Routers FastAPI (Auth, Invitados,      │
│   Presupuesto) + Controllers Flutter     │
├─────────────────────────────────────────┤
│           Capa de Dominio                │
│   Models (Invitado, Presupuesto, Auth)   │
│   Services Flutter + Business Logic API  │
├─────────────────────────────────────────┤
│           Capa de Infraestructura        │
│   Data Store in-memory + ApiClient HTTP  │
│   JWT Auth + Prometheus + OpenTelemetry  │
└─────────────────────────────────────────┘
```

**Paquetes principales:**
- `services/routers/` — controladores REST
- `services/auth/` — autenticación JWT
- `services/models/` — modelos de dominio
- `services/data/` — almacenamiento
- `client/lib/` — cliente Flutter por capas (Clean Architecture)

---

### Vista de Proceso — ¿Cómo fluyen los datos?

Describe los procesos concurrentes y la comunicación entre ellos.

```
Proceso 1: uvicorn (servidor ASGI)
  ├── Request llega → FastAPI procesa → Response
  ├── Prometheus instrumentator registra métricas
  └── OpenTelemetry genera span → envía a Jaeger

Proceso 2: Prometheus (scraping)
  └── Cada 10s → GET /metrics → almacena serie de tiempo

Proceso 3: Grafana (consulta)
  └── Consulta Prometheus → renderiza dashboards

Proceso 4: Promtail (recolección de logs)
  └── Lee logs Docker → envía a Loki

Proceso 5: Flutter app
  └── Circuit Breaker → ApiClient → HTTP → Weddy API
```

---

### Vista de Desarrollo — ¿Cómo está organizado el código?

```
software-proyecto/
├── client/                    # App Flutter (Servicio Consumidor)
│   ├── lib/
│   │   ├── controllers/       # Capa de presentación
│   │   ├── services/          # Lógica de negocio
│   │   ├── repositories/      # Abstracción de datos
│   │   ├── data/              # Datasources local y remoto
│   │   ├── models/            # Entidades de dominio
│   │   └── patterns/          # Circuit Breaker, Factory, Observer
│   └── test/
├── services/                  # Backend FastAPI (Servicio Proveedor)
│   ├── routers/               # Endpoints REST
│   ├── auth/                  # JWT y dependencias
│   ├── models/                # Schemas Pydantic
│   ├── data/                  # Store en memoria
│   ├── telemetry/             # OpenTelemetry
│   └── tests/                 # PyTest unit + mock tests
├── tests/
│   ├── api/                   # Colección Postman/Newman
│   ├── load/                  # k6 load test
│   └── gui/                   # Cypress E2E tests
├── monitoring/                # Prometheus, Grafana, Loki, Promtail
├── k8s/                       # Manifiestos Kubernetes
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── secret.yaml
│   ├── rbac.yaml
│   └── network-policy.yaml
└── .github/workflows/         # CI/CD pipelines
```

---

### Vista Física — ¿Dónde se despliega?

Mapea los componentes lógicos a nodos de infraestructura.

```
┌─────────────────────────────────────────────────────┐
│              Cluster Kubernetes (weddy ns)           │
│                                                     │
│  ┌────────────────┐    ┌─────────────────────────┐  │
│  │  Pod: backend  │    │  Pod: observabilidad    │  │
│  │  (2 réplicas)  │    │  prometheus+grafana+    │  │
│  │  :8000         │    │  loki+promtail+jaeger   │  │
│  └────────────────┘    └─────────────────────────┘  │
│         │                          │                  │
│  ┌──────▼──────────────────────────▼──────────────┐  │
│  │          Network Policy (weddy-backend-netpol)  │  │
│  │  Ingress: solo desde namespace monitoring       │  │
│  │  Egress: DNS + Jaeger :4318 + HTTPS :443        │  │
│  └─────────────────────────────────────────────────┘  │
│                                                     │
│  RBAC: weddy-backend-sa (mínimo privilegio)         │
│  Secrets: weddy-secret (SECRET_KEY, JAEGER_HOST)    │
└─────────────────────────────────────────────────────┘

Alternativa local: docker compose up
  → weddy-backend, prometheus, grafana, jaeger, loki, promtail
```

---

### Vista de Escenarios (Casos de Uso) — ¿Cómo se usa el sistema?

Los escenarios validan que las cuatro vistas anteriores satisfacen los requisitos.

| Escenario | Actor | Flujo | Vistas involucradas |
|---|---|---|---|
| UC-1: Login y obtener token | Usuario | App → POST /auth/login → JWT | Lógica, Proceso |
| UC-2: Registrar invitado | Usuario autenticado | App + Bearer → POST /invitados/ | Lógica, Proceso |
| UC-3: Consultar presupuesto | Usuario | App → GET /presupuesto/ → cálculo | Lógica |
| UC-4: Backend caído | Sistema | Circuit Breaker → caché local | Proceso |
| UC-5: Monitoreo en tiempo real | DevOps | Prometheus → Grafana dashboard | Física |
| UC-6: Consultar logs | DevOps | Promtail → Loki → Grafana Explore | Física |
| UC-7: Trazabilidad | DevOps | OpenTelemetry → Jaeger UI | Proceso |
| UC-8: CI/CD | Developer | git push → GitHub Actions → DockerHub | Desarrollo |
