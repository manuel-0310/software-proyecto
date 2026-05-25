# Weddy — Plataforma de Gestión de Bodas

**Proyecto 3 · Arquitecturas de Software · Universidad de La Sabana**  
Daniel Riveros · Manuel Castillo

[![CI](https://github.com/manuel-0310/software-proyecto/actions/workflows/ci.yml/badge.svg)](https://github.com/manuel-0310/software-proyecto/actions/workflows/ci.yml)
[![CD](https://github.com/manuel-0310/software-proyecto/actions/workflows/cd.yml/badge.svg)](https://github.com/manuel-0310/software-proyecto/actions/workflows/cd.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=manuel-0310_software-proyecto&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=manuel-0310_software-proyecto)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=manuel-0310_software-proyecto&metric=coverage)](https://sonarcloud.io/summary/new_code?id=manuel-0310_software-proyecto)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=manuel-0310_software-proyecto&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=manuel-0310_software-proyecto)

---

## ¿Qué es Weddy?

Weddy es una plataforma de gestión de bodas que permite administrar invitados y presupuesto desde una app móvil. Comenzó como una aplicación Flutter monolítica (Entrega 1) y evolucionó hacia una **arquitectura orientada a servicios** con backend REST independiente, resiliencia ante fallos, observabilidad en tiempo real y autenticación JWT (Entrega 2 y 3).

---

## Stack tecnológico

| Capa | Tecnología | Descripción |
|---|---|---|
| **Backend** | FastAPI · Python 3.11 | API REST con autenticación JWT y métricas Prometheus |
| **App móvil** | Flutter · Dart | Cliente con Circuit Breaker y fallback a caché |
| **Observabilidad** | Prometheus · Grafana · Jaeger | Métricas, dashboards y trazabilidad distribuida |
| **CI/CD** | GitHub Actions | Pipeline de 9 jobs: lint → test → análisis → build → deploy |
| **Análisis estático** | SonarCloud | Quality Gate activo con cobertura del 82.5% |

---

## Estructura del repositorio

```
software-proyecto/
├── services/          # Backend FastAPI (Python 3.11)
│   ├── main.py
│   ├── auth/          # JWT + bcrypt
│   ├── routers/       # Endpoints REST
│   ├── telemetry/     # OpenTelemetry → Jaeger
│   ├── tests/         # 30 tests pytest
│   └── Dockerfile
├── client/            # App Flutter
│   └── lib/
│       ├── patterns/circuit_breaker/   # Circuit Breaker implementado
│       └── data/remote/               # Datasources con fallback
├── monitoring/        # Docker Compose: Jaeger
│   └── docker-compose.yml
├── docs/              # Documentación técnica completa
│   ├── informe-tecnico.md   ← documento principal
│   ├── guia-ejecucion.md
│   ├── resiliencia.md
│   ├── observabilidad.md
│   └── seguridad.md
└── diagramas/         # Diagramas C4 y arquitecturales
```

---

## Inicio rápido

> Requisitos: Python 3.11, Flutter, Docker Desktop. Ver [guía completa](docs/guia-ejecucion.md).

**Terminal 1 — Backend:**
```bash
cd services
source .venv/bin/activate          # Windows: .venv\Scripts\activate
JAEGER_ENABLED=true uvicorn main:app --host 0.0.0.0
```

**Terminal 2 — Observabilidad:**
```bash
brew services start prometheus
brew services start grafana
cd monitoring && docker compose up -d
```

**Terminal 3 — App:**
```bash
cd client && flutter run
```

| Servicio | URL | Credenciales |
|---|---|---|
| API Docs | http://localhost:8000/docs | — |
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3000 | admin / weddy2024 |
| Jaeger | http://localhost:16686 | — |

---

## Documentación

| Documento | Contenido |
|---|---|
| [informe-tecnico.md](docs/informe-tecnico.md) | Informe técnico completo: arquitectura C4, patrones, CI/CD, DevSecOps, pruebas, resiliencia, observabilidad, seguridad |
| [guia-ejecucion.md](docs/guia-ejecucion.md) | Cómo instalar, configurar y ejecutar el proyecto paso a paso |
| [resiliencia.md](docs/resiliencia.md) | Investigación y evidencia del patrón Circuit Breaker |
| [observabilidad.md](docs/observabilidad.md) | Configuración y evidencia de Prometheus, Grafana y Jaeger |
| [seguridad.md](docs/seguridad.md) | Autenticación JWT: flujo, endpoints protegidos y evidencia |

---

## Patrones y atributos de calidad

- **Circuit Breaker + Fallback** — tras 3 fallos consecutivos la app sirve datos desde caché y muestra banner; reconecta automáticamente a los 30 segundos
- **JWT HS256** — operaciones de escritura protegidas; lectura pública
- **Observabilidad de tres pilares** — métricas (Prometheus), visualización (Grafana), trazas (Jaeger)
- **CI/CD completo** — lint → 30 tests unitarios → SonarCloud → build Docker → Newman (API) → k6 (carga) → reporte consolidado
- **Quality Gate SonarCloud** — 0 bugs, 0 vulnerabilidades, Security Rating A, cobertura ≥ 80%

---

## Créditos

- **Daniel Riveros** — Diseño de Experiencia de Usuario (UI/UX), Integración Frontend y Dirección Creativa
- **Manuel Castillo** — Arquitectura de Software e Implementación de Patrones
