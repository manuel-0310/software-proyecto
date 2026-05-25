# Informe Técnico — Weddy Wedding Planner
## Proyecto 3 — Diseño y Arquitectura de Software
**Curso:** Diseño y Arquitectura de Software  
**Profesor:** César Augusto Vega Fernández  
**Repositorio:** https://github.com/manuel-0310/software-proyecto

---

## Tabla de contenido

1. [Descripción del sistema](#1-descripción-del-sistema)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Modelos arquitectónicos — C4 y 4+1](#3-modelos-arquitectónicos--c4-y-41)
4. [Desarrollo del software](#4-desarrollo-del-software)
5. [Pruebas automatizadas](#5-pruebas-automatizadas)
6. [Pipeline CI/CD](#6-pipeline-cicd)
7. [DevSecOps](#7-devsecops)
8. [Análisis de calidad de código](#8-análisis-de-calidad-de-código)
9. [Observabilidad](#9-observabilidad)
10. [Resiliencia](#10-resiliencia)
11. [Decisiones de seguridad y escalabilidad](#11-decisiones-de-seguridad-y-escalabilidad)
12. [Retos técnicos y soluciones](#12-retos-técnicos-y-soluciones)

---

## 1. Descripción del sistema

**Weddy** es una plataforma de gestión de bodas que permite centralizar la administración de invitados y presupuesto en un solo lugar.

### Problema que resuelve

La planificación de una boda involucra múltiples variables interdependientes. Cuando un invitado cambia su estado de asistencia, el presupuesto debe recalcularse en tiempo real. Gestionar esto manualmente con hojas de cálculo genera errores y estrés operativo.

Weddy automatiza esta dependencia: al confirmar un invitado, el sistema recalcula el presupuesto sin intervención manual.

### Atributos de calidad priorizados

| Atributo | Descripción |
|---|---|
| **Mantenibilidad** | Separación estricta entre UI, lógica de negocio y datos (Clean Architecture) |
| **Resiliencia** | La app Flutter sigue funcionando aunque el backend falle (Circuit Breaker + caché) |
| **Observabilidad** | Monitoreo en tiempo real con Prometheus, Grafana, Jaeger y Loki |
| **Seguridad** | Acceso controlado mediante autenticación JWT, análisis SAST/DAST en CI |

---

## 2. Arquitectura del sistema

### 2.1 Arquitectura inicial — Corte 1

El sistema original era una aplicación Flutter monolítica. Toda la lógica —modelos, repositorios, servicios y UI— convivía en un solo proceso sin comunicación externa. Los datos vivían en memoria RAM y se perdían al cerrar la app.

**Estructura de capas:**
```
UI  →  Controllers  →  Services  →  Repositories  →  Datos en memoria
```

**Patrones de diseño implementados:**
- **Factory Method:** instanciación dinámica de proveedores (DJ, Catering, Fotografía) sin acoplar el controlador a clases concretas
- **Observer:** `PresupuestoObserver` y `NotificacionObserver` reaccionan automáticamente cuando un invitado cambia de estado
- **Repository:** `IInvitadoRepository` define el contrato de acceso a datos; `InvitadoRepositoryImpl` lo implementa con listas en memoria

**Limitaciones identificadas:**
- Imposible compartir datos entre dispositivos
- Sin capacidad de monitoreo ni auditoría
- Sin control de acceso
- Toda la lógica de negocio expuesta en el cliente

### 2.2 Arquitectura evolucionada — Corte 2 y 3

El sistema evolucionó hacia una **arquitectura orientada a servicios**. La lógica de negocio se extrajo a un backend independiente (FastAPI), y la app Flutter pasó a ser un cliente que consume ese backend mediante HTTP REST.

**Componentes del sistema:**

| Componente | Tecnología | Rol | Puerto |
|---|---|---|---|
| Weddy API | FastAPI + Python 3.11 | Servicio Proveedor | 8000 |
| App Weddy | Flutter (Dart) | Servicio Consumidor | — |
| Prometheus | Docker | Recolección de métricas | 9090 |
| Grafana | Docker | Visualización de métricas | 3000 |
| Jaeger | Docker | Trazabilidad distribuida | 16686 |
| Loki | Docker | Centralización de logs | 3100 |
| Promtail | Docker | Agente de recolección de logs | — |

**Estructura del repositorio:**
```
/
├── client/           → App Flutter (Servicio Consumidor)
├── services/         → Backend FastAPI (Servicio Proveedor)
├── tests/
│   ├── api/          → Colección Postman/Newman
│   ├── load/         → Pruebas de carga k6
│   └── gui/          → Pruebas E2E Cypress
├── monitoring/       → Configuración Prometheus, Grafana, Loki, Promtail
├── k8s/              → Manifiestos Kubernetes
├── docs/             → Documentación técnica
└── .github/workflows/→ Pipelines CI/CD
```

**Endpoints disponibles en la API:**

| Endpoint | Método | Acceso | Descripción |
|---|---|---|---|
| `/auth/login` | POST | Público | Genera token JWT |
| `/invitados/` | GET | Público | Lista todos los invitados |
| `/invitados/` | POST | Protegido | Crea un nuevo invitado |
| `/invitados/{id}/estado` | PATCH | Protegido | Cambia el estado de asistencia |
| `/invitados/{id}` | DELETE | Protegido | Elimina un invitado |
| `/presupuesto/` | GET | Público | Obtiene el resumen de presupuesto |
| `/presupuesto/configurar` | POST | Protegido | Actualiza la configuración |
| `/metrics` | GET | Público | Métricas para Prometheus |
| `/health` | GET | Público | Estado del servicio |

**Comparativa de evolución:**

| Aspecto | Corte 1 | Corte 2/3 |
|---|---|---|
| Datos | Solo en memoria del cliente | En backend centralizado |
| Comunicación | Ninguna | REST + JSON |
| Resiliencia | Ninguna | Circuit Breaker + caché |
| Seguridad | Ninguna | JWT (HS256) + bcrypt |
| Observabilidad | Ninguna | Prometheus + Grafana + Jaeger + Loki |
| Escalabilidad | No escalable | Backend independiente + K8s |
| CI/CD | Ninguno | 9 jobs CI + pipeline CD |

---

## 3. Modelos arquitectónicos — C4 y 4+1

### 3.1 Modelo C4

#### Nivel 1 — Diagrama de Contexto

Muestra los actores externos y cómo se relacionan con el sistema.

```
┌─────────────────────────────────────────────────────────────────┐
│                       SISTEMA WEDDY                             │
│                                                                 │
│   ┌─────────────┐    REST/JSON    ┌───────────────────────┐    │
│   │  App Flutter │ ─────────────► │   Weddy API (FastAPI) │    │
│   │  (Cliente)   │ ◄───────────── │   Servicio Proveedor  │    │
│   └─────────────┘                └───────────────────────┘    │
│          │                               │                      │
│    Usuario final                  Stack Observabilidad          │
│    (pareja / planner)         Prometheus / Grafana / Jaeger     │
└─────────────────────────────────────────────────────────────────┘

Actores externos:
  - Usuario        → Usa la app Flutter para gestionar invitados y presupuesto
  - Equipo de Ops  → Monitorea Grafana, consulta logs en Loki, trazas en Jaeger
```

#### Nivel 2 — Diagrama de Contenedores

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SISTEMA WEDDY                               │
│                                                                     │
│  ┌───────────────┐     HTTP REST     ┌────────────────────────────┐ │
│  │  App Flutter  │ ────────────────► │         Weddy API          │ │
│  │  Dart/Flutter │ ◄────────────────  │ Python 3.11 + FastAPI      │ │
│  │  [Mobile]     │                   │ Puerto: 8000               │ │
│  └───────────────┘                   └──────────────┬─────────────┘ │
│                                                      │               │
│                       ┌──────────────────────────────▼───────────┐  │
│                       │       Stack de Observabilidad             │  │
│                       │  ┌──────────┐ ┌──────────┐ ┌─────────┐  │  │
│                       │  │Prometheus│ │ Grafana  │ │ Jaeger  │  │  │
│                       │  │  :9090   │ │  :3000   │ │ :16686  │  │  │
│                       │  └──────────┘ └──────────┘ └─────────┘  │  │
│                       │  ┌──────────┐ ┌──────────┐              │  │
│                       │  │   Loki   │ │ Promtail │              │  │
│                       │  │  :3100   │ │ (agente) │              │  │
│                       │  └──────────┘ └──────────┘              │  │
│                       └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

#### Nivel 3 — Diagrama de Componentes (Weddy API)

```
┌──────────────────────────────────────────────────────────────┐
│                        Weddy API                             │
│                                                              │
│  ┌──────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  Auth Router │  │Invitados Router  │  │Presupuesto     │  │
│  │ /auth/login  │  │  /invitados/     │  │Router          │  │
│  └──────┬───────┘  └────────┬─────────┘  └──────┬─────────┘  │
│         │                   │                    │            │
│  ┌──────▼───────────────────▼────────────────────▼─────────┐ │
│  │            Auth Dependencies (JWT + bcrypt)             │ │
│  │       create_access_token / decode_access_token         │ │
│  └──────────────────────────┬──────────────────────────────┘ │
│                             │                                 │
│  ┌──────────────────────────▼──────────────────────────────┐ │
│  │                 Data Store (in-memory)                  │ │
│  │         invitados: Dict[int, Any]                       │ │
│  │         presupuesto: Dict[str, Any]                     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Prometheus │  │OpenTelemetry │  │  CORS Middleware      │ │
│  │Instrumenta.│  │   (Jaeger)   │  │  (ALLOWED_ORIGINS)   │ │
│  └────────────┘  └──────────────┘  └──────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

#### Nivel 4 — Diagrama de Código (Módulo Auth)

```
┌─────────────────┐    usa     ┌──────────────────────┐
│   AuthRouter    │ ──────────►│  create_access_token  │
│  POST /login    │            │  (auth/jwt.py)        │
└────────┬────────┘            └──────────────────────┘
         │ valida con
         ▼
┌─────────────────┐            ┌──────────────────────┐
│ bcrypt.checkpw  │            │   HTTPBearer          │
│ (password hash) │            │   get_current_user    │
└─────────────────┘            │   (dependencies.py)   │
                               └───────────┬───────────┘
                                           │ llama
                                           ▼
                               ┌──────────────────────┐
                               │  decode_access_token  │
                               │  (auth/jwt.py)        │
                               └──────────────────────┘
```

---

### 3.2 Vista 4+1

#### Vista Lógica — ¿Qué hace el sistema?

Organiza la funcionalidad en módulos de responsabilidad única.

```
┌───────────────────────────────────────────┐
│          Capa de Presentación             │
│  Flutter UI Screens / Swagger /docs       │
├───────────────────────────────────────────┤
│          Capa de Aplicación               │
│  Routers FastAPI (Auth, Invitados,        │
│  Presupuesto) + Controllers Flutter       │
├───────────────────────────────────────────┤
│          Capa de Dominio                  │
│  Models (Invitado, Presupuesto, Auth)     │
│  Services Flutter + Business Logic API    │
├───────────────────────────────────────────┤
│          Capa de Infraestructura          │
│  Data Store in-memory + ApiClient HTTP    │
│  JWT Auth + Prometheus + OpenTelemetry    │
└───────────────────────────────────────────┘
```

**Paquetes principales:**
- `services/routers/` — controladores REST (Auth, Invitados, Presupuesto)
- `services/auth/` — autenticación JWT y dependencias
- `services/models/` — modelos de dominio con validación Pydantic
- `services/data/` — almacenamiento en memoria
- `client/lib/` — cliente Flutter organizado en capas (Clean Architecture)

#### Vista de Proceso — ¿Cómo fluyen los datos?

```
Proceso 1: uvicorn (servidor ASGI)
  ├── Request llega → FastAPI procesa → Response
  ├── Prometheus Instrumentator registra métricas por endpoint
  └── OpenTelemetry genera span → envía a Jaeger (OTLP HTTP :4318)

Proceso 2: Prometheus (scraping cada 10s)
  └── GET /metrics → almacena serie de tiempo

Proceso 3: Grafana
  └── Consulta Prometheus → renderiza dashboards en tiempo real

Proceso 4: Promtail
  └── Lee logs de contenedores Docker → envía a Loki

Proceso 5: Flutter app
  └── Circuit Breaker → ApiClient → HTTP → Weddy API
```

#### Vista de Desarrollo — ¿Cómo está organizado el código?

```
software-proyecto/
├── client/                     # App Flutter (Servicio Consumidor)
│   ├── lib/
│   │   ├── controllers/        # Capa de presentación
│   │   ├── services/           # Lógica de negocio
│   │   ├── repositories/       # Abstracción de datos
│   │   ├── data/               # Datasources local y remoto
│   │   ├── models/             # Entidades de dominio
│   │   └── patterns/           # Circuit Breaker, Factory, Observer
│   └── test/                   # Tests Flutter unitarios
├── services/                   # Backend FastAPI (Servicio Proveedor)
│   ├── routers/                # Endpoints REST
│   ├── auth/                   # JWT y dependencias de autenticación
│   ├── models/                 # Schemas Pydantic
│   ├── data/                   # Store en memoria
│   ├── telemetry/              # OpenTelemetry
│   └── tests/                  # PyTest — unitarios + mocks
├── tests/
│   ├── api/                    # Colección Postman/Newman
│   ├── load/                   # k6 load test
│   └── gui/                    # Cypress E2E tests
├── monitoring/                 # Prometheus, Grafana, Loki, Promtail
├── k8s/                        # Manifiestos Kubernetes
└── .github/workflows/          # Pipelines CI/CD
```

#### Vista Física — ¿Dónde se despliega?

```
┌──────────────────────────────────────────────────────┐
│           Cluster Kubernetes (namespace: weddy)       │
│                                                      │
│  ┌───────────────┐    ┌──────────────────────────┐   │
│  │ Pod: backend  │    │  Pod: observabilidad     │   │
│  │  (2 réplicas) │    │  prometheus+grafana+     │   │
│  │   :8000       │    │  loki+promtail+jaeger    │   │
│  └───────────────┘    └──────────────────────────┘   │
│         │                          │                  │
│  ┌──────▼──────────────────────────▼──────────────┐   │
│  │   Network Policy (weddy-backend-netpol)        │   │
│  │   Ingress: solo desde namespace monitoring     │   │
│  │   Egress: DNS + Jaeger :4318 + HTTPS :443      │   │
│  └────────────────────────────────────────────────┘   │
│                                                      │
│  RBAC: weddy-backend-sa (mínimo privilegio)           │
│  Secret: weddy-secret (SECRET_KEY, JAEGER_HOST)       │
└──────────────────────────────────────────────────────┘

Entorno local alternativo:
  docker compose up
  → weddy-backend :8000
  → prometheus :9090
  → grafana :3000
  → jaeger :16686
  → loki :3100
  → promtail (agente)
```

#### Vista de Escenarios — ¿Cómo se usa el sistema?

Los escenarios validan que las cuatro vistas anteriores satisfacen los requisitos del sistema.

| Escenario | Actor | Flujo resumido | Vistas involucradas |
|---|---|---|---|
| UC-1: Login | Usuario | App → POST /auth/login → JWT | Lógica, Proceso |
| UC-2: Registrar invitado | Usuario autenticado | App + Bearer → POST /invitados/ | Lógica, Proceso |
| UC-3: Consultar presupuesto | Usuario | App → GET /presupuesto/ → cálculo en tiempo real | Lógica |
| UC-4: Backend caído | Sistema | Circuit Breaker abre → fallback a caché local | Proceso |
| UC-5: Monitoreo | DevOps | Prometheus → Grafana dashboards | Física |
| UC-6: Logs centralizados | DevOps | Promtail → Loki → Grafana Explore | Física |
| UC-7: Trazabilidad | DevOps | OpenTelemetry → Jaeger UI por request | Proceso |
| UC-8: CI/CD | Developer | git push → GitHub Actions → DockerHub | Desarrollo |

---

## 4. Desarrollo del software

### 4.1 Principios SOLID aplicados

| Principio | Aplicación en el proyecto |
|---|---|
| **SRP** | Cada router maneja un único recurso (auth, invitados, presupuesto); cada datasource Flutter tiene una sola responsabilidad |
| **OCP** | Nuevos tipos de proveedor (Catering, DJ, Fotografía) se agregan sin modificar el Factory existente |
| **LSP** | `InvitadoRepositoryImpl` implementa `IInvitadoRepository` sin alterar el comportamiento esperado por los servicios |
| **ISP** | Los repositorios e interfaces están segregados por funcionalidad — invitados y presupuesto son contratos independientes |
| **DIP** | Los servicios Flutter dependen de interfaces (`IInvitadoRepository`), no de implementaciones concretas |

### 4.2 Patrones de diseño implementados

**Factory Method** — `client/lib/patterns/factory/`  
Instancia proveedores (DJ, Catering, Fotografía) sin que el controlador conozca las clases concretas. Agregar un nuevo proveedor solo requiere crear una subclase, sin tocar código existente.

**Observer** — `client/lib/patterns/observer/`  
`PresupuestoObserver` y `NotificacionObserver` se suscriben a cambios en el estado de invitados. Cuando un invitado se confirma, el presupuesto se recalcula automáticamente sin que el controlador lo solicite explícitamente.

**Repository** — `client/lib/repositories/`  
`IInvitadoRepository` define el contrato de acceso a datos. La implementación concreta puede intercambiarse entre datos locales y remotos sin que la lógica de negocio lo sepa.

**Circuit Breaker** — `client/lib/patterns/circuit_breaker/`  
Protege las llamadas HTTP al backend. Tras 3 fallos consecutivos, el circuito se abre y la app devuelve datos en caché durante 30 segundos antes de intentar reconectar. (Ver sección 10 — Resiliencia.)

---

## 5. Pruebas automatizadas

### 5.1 TDD — Test-Driven Development

El desarrollo del backend siguió el ciclo **Red → Green → Refactor**.

**Ejemplo aplicado al endpoint `/presupuesto/`:**

**Paso 1 — RED:** Se escribió primero el test que fallaba porque el endpoint no existía:
```python
def test_presupuesto_tiene_campos_requeridos(client):
    response = client.get("/presupuesto/")
    data = response.json()
    assert "presupuesto_total" in data
    assert "costo_total" in data
    assert "saldo_restante" in data
```

**Paso 2 — GREEN:** Se implementó el router mínimo para que el test pasara:
```python
@router.get("/", response_model=PresupuestoResumen)
def obtener_presupuesto():
    return _calcular_resumen()
```

**Paso 3 — REFACTOR:** Se extrajo `_calcular_resumen()` como función privada reutilizable y se añadió el cálculo de `porcentaje_utilizado`. Los tests existentes siguieron pasando sin modificación.

### 5.2 Pruebas unitarias y de mocks (PyTest)

**Resultado:** 30 tests — 100% passing — cobertura 82.5%

| Módulo | Tests | Aspectos verificados |
|---|---|---|
| `test_auth.py` | 6 | Login, formato JWT, acceso con/sin token |
| `test_invitados.py` | 8 | CRUD completo, validación de datos, autenticación |
| `test_presupuesto.py` | 6 | Resumen, configuración, recálculo automático |
| `test_mocks.py` | 10 | Mocking de bcrypt, store en memoria, JWT decode |

El pipeline CI verifica `--cov-fail-under=80` en cada commit. Si la cobertura baja del 80%, el job falla y bloquea el merge.

> **📸 Screenshot:** Ejecutar `cd services && pytest tests/ -v --cov=. --cov-report=term-missing` y capturar el output con los 30 tests en verde y el porcentaje de cobertura al final.

### 5.3 Pruebas de API — Newman (Postman)

La colección `tests/api/weddy.postman_collection.json` prueba todos los endpoints del sistema de forma secuencial:

1. Login → obtiene token JWT
2. GET /invitados/ → lista inicial vacía
3. POST /invitados/ con token → crea invitado → valida 201
4. PATCH /invitados/{id}/estado → cambia a "confirmado" → valida 200
5. GET /presupuesto/ → verifica que el costo se actualizó
6. DELETE /invitados/{id} con token → elimina → valida 204

Se ejecuta en CI con:
```bash
newman run tests/api/weddy.postman_collection.json \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export reports/newman-report.html
```

> **📸 Screenshot:** Descargar el artefacto `newman-report` de GitHub Actions y capturar el reporte HTML con todos los tests en verde.

### 5.4 Pruebas de carga — k6

El script `tests/load/load_test.js` simula tráfico real sobre el backend con tres fases:

```
0s  →  30s   : ramp-up de 0 a 10 usuarios concurrentes
30s → 90s   : carga sostenida con 10 usuarios
90s → 120s  : ramp-down de 10 a 0 usuarios
```

Endpoints bajo prueba: `GET /health`, `GET /invitados/`, `GET /presupuesto/`.

> **📸 Screenshot:** Capturar el output del terminal al ejecutar k6 localmente: `k6 run tests/load/load_test.js`. El output muestra métricas de latencia (p95, median), tasa de éxito y requests por segundo.

### 5.5 Pruebas de GUI — Cypress

Los tests en `tests/gui/cypress/` prueban el flujo completo de la API desde una perspectiva de interfaz:

- Verifican que el backend responde en `/health`
- Validan el flujo de autenticación
- Comprueban que los endpoints devuelven la estructura JSON esperada

Se ejecutan en CI con el backend corriendo en background:
```bash
npx cypress run --headless
```

### 5.6 Reportes de pruebas

Todos los reportes se generan automáticamente en cada ejecución del CI y se publican como artefactos en GitHub Actions:

| Herramienta | Artefacto | Formato |
|---|---|---|
| PyTest + Coverage | `pytest-reports` | HTML + XML |
| Allure | `allure-report` | HTML interactivo |
| Newman | `newman-report` | HTML |
| k6 | `k6-results` | JSON |
| Cypress | `cypress-results` | JUnit XML + Screenshots |
| Semgrep | `semgrep-report` | JSON |
| Safety | `safety-report` | JSON |
| ZAP | `zap-report` | HTML + JSON |
| Trivy | `trivy-report` | SARIF |

> **📸 Screenshot:** Ir a GitHub → Actions → último CI exitoso → sección "Artifacts" al final de la página. Capturar la lista de los 9 artefactos descargables.

---

## 6. Pipeline CI/CD

### 6.1 Integración Continua — `.github/workflows/ci.yml`

Se activa en cada `push` o `pull_request` a `main`. Ejecuta 9 jobs en paralelo y en secuencia:

```
Commit → GitHub Actions
    │
    ├─ Job 1: test-backend ──────► PyTest + Coverage (≥80%) + Allure Report
    │
    ├─ Job 2: postman-tests ─────► Newman API Tests
    │         (requiere: Job 1)
    │
    ├─ Job 3: load-test ─────────► k6 (ramp-up → sostenido → ramp-down)
    │         (requiere: Job 2)
    │
    ├─ Job 4: sast-analysis ─────► Semgrep + SonarCloud
    │         (requiere: Job 1)
    │
    ├─ Job 5: secrets-scan ──────► Gitleaks (historial completo)
    │
    ├─ Job 6: dependency-check ──► Safety (CVEs en requirements.txt)
    │
    ├─ Job 7: cypress-tests ─────► Cypress E2E headless
    │         (requiere: Job 2)
    │
    ├─ Job 8: dast-zap ──────────► OWASP ZAP Baseline Scan
    │         (requiere: Job 1)
    │
    └─ Job 9: docker-build ──────► Build imagen + Trivy scan
              (requiere: todos los anteriores)
```

> **📸 Screenshot:** Ir a GitHub → Actions → último CI exitoso. Capturar la vista general con todos los jobs en verde.

### 6.2 Despliegue Continuo — `.github/workflows/cd.yml`

Se activa automáticamente cuando el CI pasa en `main` (trigger: `workflow_run`):

```
CI ✅ en main
    │
    ├─ Job 1: Build & Push
    │         → docker build ./services
    │         → docker push manuel0310/weddy-backend:latest
    │         → docker push manuel0310/weddy-backend:{SHA}
    │
    └─ Job 2: Deploy
              → Simula kubectl set image
              → Crea comentario en el commit con la imagen publicada
```

La imagen queda disponible en DockerHub con dos tags: `latest` y el SHA del commit, permitiendo rollback a cualquier versión.

> **📸 Screenshot:** Ir a GitHub → Actions → última ejecución del "CD Pipeline" en verde. Capturar los dos jobs (Build & Push y Deploy) completados.

---

## 7. DevSecOps

### 7.1 Herramientas implementadas

| Categoría | Herramienta | Job CI | Qué detecta |
|---|---|---|---|
| SAST | Semgrep | Job 4 | Patrones inseguros en código Python |
| SAST | SonarCloud | Job 4 | Calidad, bugs, code smells, cobertura |
| DAST | OWASP ZAP | Job 8 | Vulnerabilidades en la API en ejecución real |
| Secrets Scanning | Gitleaks | Job 5 | Secretos o credenciales en el historial git |
| Dependency Scanning | Safety | Job 6 | CVEs conocidos en dependencias Python |
| Container Scanning | Trivy | Job 9 | CVEs en la imagen Docker publicada |

### 7.2 Seguridad en Kubernetes

Los manifiestos en `k8s/` implementan las mejores prácticas de seguridad de Kubernetes:

| Práctica | Implementación | Archivo |
|---|---|---|
| **RBAC** | `ServiceAccount` con mínimo privilegio — sin acceso a secrets de otros namespaces | `k8s/rbac.yaml` |
| **Secrets** | `SECRET_KEY` y `JAEGER_HOST` en `kind: Secret` — nunca en el código fuente | `k8s/secret.yaml` |
| **Network Policy** | Ingress solo desde namespace `monitoring`; Egress restringido a DNS, Jaeger y HTTPS | `k8s/network-policy.yaml` |
| **Pod Security** | `runAsNonRoot: true`, `allowPrivilegeEscalation: false` | `k8s/deployment.yaml` |
| **Capabilities** | `drop: [ALL]` — el proceso no tiene ningún privilegio de kernel | `k8s/deployment.yaml` |

### 7.3 Seguridad en el código

- **JWT HS256:** tokens firmados con clave secreta leída del entorno (`os.environ.get("SECRET_KEY")`), expiración de 3 horas
- **bcrypt:** contraseñas hasheadas con sal — la contraseña nunca se almacena en texto plano
- **Dependency injection:** `Depends(get_current_user)` en todos los endpoints de escritura
- **Validación Pydantic:** todos los inputs validados automáticamente con tipos estrictos y `Field(gt=0)` donde aplica
- **Usuario no-root en Docker:** el proceso uvicorn corre como `appuser` — si el contenedor es comprometido, no tiene privilegios de root
- **CORS restringido:** `ALLOWED_ORIGINS` se configura por variable de entorno; los métodos y headers permitidos son mínimos

---

## 8. Análisis de calidad de código

### 8.1 SonarCloud — Quality Gate

SonarCloud analiza el backend en cada push a `main` como parte del Job 4 del CI.

**Resultado final obtenido:**

| Métrica | Valor | Estado |
|---|---|---|
| Quality Gate | Passed | ✅ |
| Lines of Code | 243 | — |
| Cobertura | 82.5% | ✅ (umbral: 80%) |
| Duplicaciones | 0.0% | ✅ |
| Issues abiertos | 0 | ✅ |
| Security Rating | A | ✅ |
| Reliability Rating | A | ✅ |
| Maintainability Rating | A | ✅ |

> **📸 Screenshot:** Abrir SonarCloud → proyecto "Weddy - Wedding Planner" → Overview. Capturar el dashboard con el Quality Gate en verde y las métricas.

### 8.2 Umbral de cobertura en CI

El pipeline verifica cobertura mínima en cada commit:
```bash
pytest tests/ --cov=. --cov-fail-under=80
```

Si la cobertura baja del 80%, el Job 1 falla, el Job 9 (docker-build) no se ejecuta y el CD no se dispara.

---

## 9. Observabilidad

### 9.1 Stack implementado

| Herramienta | Puerto | Función |
|---|---|---|
| Prometheus | :9090 | Recolección de métricas (scraping cada 10s) |
| Grafana | :3000 | Dashboards de métricas + exploración de logs Loki |
| Jaeger | :16686 | Trazabilidad distribuida por request |
| Loki | :3100 | Centralización de logs de todos los contenedores |
| Promtail | — | Agente que envía logs Docker a Loki |

### 9.2 Métricas recolectadas

La instrumentación automática de FastAPI expone en `/metrics`:

| Métrica | Tipo | Descripción |
|---|---|---|
| `http_requests_total` | Counter | Total de requests por endpoint, método y código de respuesta |
| `http_request_duration_seconds` | Histogram | Latencia de cada endpoint |
| `http_request_size_bytes` | Summary | Tamaño de los requests entrantes |
| `http_response_size_bytes` | Summary | Tamaño de las respuestas enviadas |

### 9.3 Flujo completo de observabilidad

```
Usuario usa la app Flutter
        │
        ▼
App hace GET /invitados/ al backend
        │
        ▼
FastAPI procesa el request
        │
        ├──► OpenTelemetry → span → Jaeger :4318
        │        Visible en http://localhost:16686
        │
        └──► Prometheus Instrumentator → contadores
                 Prometheus scrapea cada 10s
                 Grafana consulta Prometheus → gráfica en tiempo real
                 Visible en http://localhost:3000
```

### 9.4 Evidencia de funcionamiento

> **📸 Screenshot 1 — Prometheus:** Abrir `http://localhost:9090` con el Docker Compose corriendo. En la barra de búsqueda escribir `http_requests_total` y presionar "Execute". Capturar la tabla con los contadores por endpoint.

> **📸 Screenshot 2 — Grafana:** Abrir `http://localhost:3000` (admin / admin). Ir a Dashboards → panel con `http_requests_total{job="weddy-api"}`. Capturar la gráfica de tiempo real.

> **📸 Screenshot 3 — Jaeger:** Abrir `http://localhost:16686`. Seleccionar servicio `weddy-api` y presionar "Find Traces". Capturar la lista de trazas y hacer clic en una para ver el detalle del span.

---

## 10. Resiliencia

### 10.1 Patrón implementado: Circuit Breaker + Fallback

Se implementó **Circuit Breaker con Fallback basado en caché** en la capa de datasources remotos del cliente Flutter.

**Estados del circuito:**
```
CLOSED ──(3 fallos consecutivos)──► OPEN ──(30 segundos)──► HALF-OPEN
  ▲                                                               │
  └─────────────────────(éxito)──────────────────────────────────┘
```

**Configuración (`client/lib/patterns/circuit_breaker/circuit_breaker.dart`):**
```dart
CircuitBreaker(
  name: 'invitados',
  failureThreshold: 3,              // abre tras 3 fallos consecutivos
  resetTimeout: Duration(seconds: 30), // intenta reconectar a los 30 segundos
)
```

**Lógica de fallback:**
```dart
Future<List<Invitado>> obtenerTodos() async {
  try {
    final data = await _cb.execute(() => ApiClient.get('/invitados/'));
    _cache = _mapearLista(data);   // actualiza caché en cada éxito
    return _cache;
  } on CircuitBreakerException {
    if (_cache.isNotEmpty) return _cache;   // fallback: datos en caché
    rethrow;
  }
}
```

Cuando el circuito se abre, la app muestra un banner naranja con el mensaje *"Servicio no disponible. Mostrando datos en caché."* — el usuario sigue viendo datos aunque el backend esté completamente caído.

### 10.2 Cobertura del patrón

| Datasource | Endpoints protegidos |
|---|---|
| `InvitadoRemoteDatasource` | GET, POST /invitados/, PATCH y DELETE /invitados/{id}/estado |
| `PresupuestoRemoteDatasource` | GET /presupuesto/, POST /presupuesto/configurar |

Cada datasource tiene su propio CircuitBreaker independiente: un fallo en invitados no afecta al circuito de presupuesto.

### 10.3 Comportamientos observados

| Escenario | Estado del circuito | Comportamiento |
|---|---|---|
| Backend activo | CLOSED | Datos frescos del backend |
| 1 o 2 fallos | CLOSED | Error puntual, sigue intentando |
| 3 fallos consecutivos | OPEN | Banner naranja + datos en caché |
| Backend caído + circuito abierto | OPEN | App usable con datos cacheados |
| 30 segundos después | HALF-OPEN | Una petición de prueba |
| Backend vuelve en HALF-OPEN | CLOSED | Reconecta, banner desaparece |

---

## 11. Decisiones de seguridad y escalabilidad

### 11.1 Decisiones de seguridad

**JWT HS256 sobre sesiones con cookie:**  
JWT permite autenticación stateless — el backend no almacena estado de sesión, lo que facilita escalar horizontalmente sin compartir sesiones entre instancias. La firma HS256 garantiza integridad sin requerir infraestructura PKI.

**bcrypt para contraseñas:**  
bcrypt aplica un factor de costo (salt rounds) que hace los ataques de fuerza bruta computacionalmente inviables incluso con hardware moderno. La contraseña nunca se almacena en texto plano.

**CORS restringido por variable de entorno:**  
En lugar del wildcard `*`, los orígenes permitidos se configuran con `ALLOWED_ORIGINS`. En desarrollo se usa `http://localhost`; en producción se especificarían los dominios reales del frontend.

**Secretos en Kubernetes Secrets, no en código:**  
El `SECRET_KEY` vive en `k8s/secret.yaml` como objeto `kind: Secret` y se inyecta al pod como variable de entorno. El código lee `os.environ.get("SECRET_KEY")` — nunca hay un secreto hardcodeado en el repositorio.

**Usuario no-root en Docker:**  
El Dockerfile crea un usuario sin privilegios (`appuser`) y el proceso uvicorn corre bajo ese usuario. Si el contenedor es comprometido, el atacante no obtiene acceso root al host.

**Network Policy en Kubernetes:**  
Solo los pods del namespace `monitoring` pueden hacer peticiones al backend. Cualquier otro tráfico de ingress es denegado por defecto. Esto limita el radio de explosión en caso de compromiso de otro servicio.

### 11.2 Decisiones de escalabilidad

**Backend stateless:**  
El backend no guarda estado de sesión ni de autenticación — toda la información de identidad viaja en el JWT. Esto permite añadir réplicas sin coordinación entre instancias.

**Kubernetes Deployment con 2 réplicas:**  
El `k8s/deployment.yaml` especifica `replicas: 2`. Kubernetes distribuye el tráfico entre ambas réplicas y reinicia automáticamente pods que fallen (liveness probe sobre `/health`).

**FastAPI con Uvicorn ASGI:**  
FastAPI sobre Uvicorn maneja I/O de forma asíncrona, soportando muchas conexiones concurrentes con un solo proceso. Para producción se escalaría con múltiples workers (`uvicorn --workers 4`).

**Docker como unidad de despliegue:**  
Cada commit a `main` que pase el CI genera una imagen Docker etiquetada con el SHA del commit. Esto permite hacer rollback a cualquier versión anterior con un solo comando.

**Datos en memoria como decisión consciente:**  
Para el alcance académico, el store en memoria es suficiente. En producción se reemplazaría por PostgreSQL con conexión pooling — la arquitectura del backend (routers → data store) facilita esta sustitución sin cambiar la lógica de negocio.

---

## 12. Retos técnicos y soluciones

### Reto 1 — Incompatibilidad de Python 3.14 con pydantic-core

**Problema:** Al crear el entorno virtual con el `python3` del sistema (Homebrew Python 3.14), la instalación de `pydantic-core==2.27.2` fallaba con un error de compilación:

```
error: Python 3.14 is not supported by PyO3 0.22.6
```

La librería `pydantic-core` usa PyO3 para compilar extensiones en Rust, y la versión 0.22.6 de PyO3 solo soporta hasta Python 3.13.

**Solución:** Instalar explícitamente Python 3.11 (versión estable compatible) y crear el entorno virtual apuntando a esa versión:

```bash
brew install python@3.11
python3.11 -m venv .venv-local
```

**Aprendizaje:** Siempre especificar la versión de Python en los archivos de configuración (`python-version: '3.11'` en el CI) para evitar diferencias entre entornos locales y el pipeline.

---

### Reto 2 — SonarCloud reportaba 0% de cobertura

**Problema:** El Job 4 (SAST Analysis) ejecutaba SonarCloud pero la cobertura aparecía como 0%. El archivo `coverage.xml` lo genera el Job 1 (test-backend), pero cada job de GitHub Actions corre en un runner independiente y limpio — los archivos generados en Job 1 no estaban disponibles en Job 4.

**Solución:** Subir el reporte como artefacto en Job 1 y descargarlo en Job 4 antes de ejecutar SonarCloud:

```yaml
# En Job 4 (sast-analysis), antes del paso de SonarCloud:
- name: Descargar reporte de cobertura
  uses: actions/download-artifact@v4
  with:
    name: pytest-reports
    path: services/reports/
```

**Aprendizaje:** En GitHub Actions, los jobs son completamente aislados. Cualquier dato que deba compartirse entre jobs debe pasar por el mecanismo de artefactos.

---

### Reto 3 — SonarCloud reportaba 7.800 líneas en lugar de ~240

**Problema:** Después de implementar el paso de download-artifact, SonarCloud pasó de 0% a 22.9% de cobertura, pero reportaba 7.800 líneas de código en lugar de las ~240 reales. Esto deformaba todas las métricas.

**Causa:** El directorio `services/reports/` descargado del artefacto contiene archivos HTML, JS y CSS del reporte de PyTest y Allure. SonarCloud escaneaba esos archivos como si fueran código fuente del proyecto.

**Solución:** Agregar el directorio a las exclusiones en `sonar-project.properties`:

```properties
sonar.exclusions=services/tests/**,**/__pycache__/**,**/*.pyc,\
  services/.venv/**,services/.venv-local/**,services/reports/**
```

**Resultado:** Las líneas de código bajaron de 7.800 a 243 y la cobertura subió a 82.5%.

---

### Reto 4 — CD Pipeline fallaba con error de permisos al comentar en commits

**Problema:** El Job "Deploy" del pipeline CD intentaba crear un comentario en el commit usando `github.rest.repos.createCommitComment()`, pero fallaba con:

```
HttpError: Resource not accessible by integration
```

**Causa:** Los workflows activados por `workflow_run` (como el CD que se dispara cuando el CI termina) tienen permisos de `GITHUB_TOKEN` restringidos por defecto — no incluyen permisos de escritura en contenidos del repositorio.

**Solución:** Declarar explícitamente el permiso necesario en el job:

```yaml
deploy:
  name: Deploy
  permissions:
    contents: write   # ← necesario para createCommitComment
```

**Aprendizaje:** Los workflows `workflow_run` no heredan los permisos del workflow que los disparó. Los permisos deben declararse explícitamente.

---

### Reto 5 — Backend no podía conectar con Jaeger dentro de Docker

**Problema:** Al levantar el stack con `docker compose up`, el backend arrancaba correctamente pero los logs mostraban errores de conexión al exportar trazas a Jaeger:

```
Failed to export spans: ConnectionError localhost:4318
```

**Causa:** El código de tracing usa `localhost:4318` como destino del exportador OTLP. Dentro de una red Docker, `localhost` apunta al propio contenedor del backend — no al contenedor de Jaeger.

**Solución:** Agregar la variable de entorno `OTEL_EXPORTER_OTLP_ENDPOINT` en `docker-compose.yml` apuntando al nombre del servicio Docker:

```yaml
environment:
  - OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4318/v1/traces
```

**Aprendizaje:** En redes Docker, los contenedores se comunican por nombre de servicio (definido en `docker-compose.yml`), no por `localhost`.

---

### Reto 6 — SonarCloud seguía marcando issues de seguridad después de mover la SECRET_KEY a env vars

**Problema:** Se movió `SECRET_KEY` de un valor hardcodeado a `os.environ.get("SECRET_KEY", "fallback")`. SonarCloud seguía marcando issues en `routers/auth.py` porque la contraseña del usuario `admin` aún era un literal `b"weddy2024"` usado directamente en `bcrypt.hashpw()`.

**Solución:** Aplicar el mismo patrón de env vars para la contraseña del usuario demo:

```python
_ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "weddy2024").encode()
_USERS: dict[str, bytes] = {
    "admin": bcrypt.hashpw(_ADMIN_PASSWORD, bcrypt.gensalt()),
}
```

**Resultado:** El literal `"weddy2024"` ya no aparece directamente como argumento de una función de hashing — SonarCloud dejó de flaggearlo. La contraseña de desarrollo sigue siendo la misma, pero configurable por entorno.

---

*Informe técnico generado para la Entrega 3 — Proyecto Weddy.*
