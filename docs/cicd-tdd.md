# CI/CD, TDD y DevSecOps — Weddy

## 1. Metodología TDD (Test-Driven Development)

El desarrollo del backend Weddy siguió el ciclo TDD: **Red → Green → Refactor**.

### Ciclo aplicado

```
1. RED   → Escribir test que falla
2. GREEN → Implementar código mínimo para que pase
3. REFACTOR → Limpiar sin romper el test
```

### Ejemplo TDD — Endpoint /presupuesto/

**Paso 1 (RED):** Se escribió primero el test:
```python
def test_presupuesto_tiene_campos_requeridos(client):
    response = client.get("/presupuesto/")
    data = response.json()
    assert "presupuesto_total" in data
    assert "costo_total" in data
    assert "saldo_restante" in data
```
→ El test **fallaba** porque el endpoint no existía.

**Paso 2 (GREEN):** Se implementó el router mínimo:
```python
@router.get("/", response_model=PresupuestoResumen)
def obtener_presupuesto():
    return _calcular_resumen()
```
→ El test **pasaba**.

**Paso 3 (REFACTOR):** Se extrajo `_calcular_resumen()` como función privada reutilizable y se añadió el cálculo de `porcentaje_utilizado`.

### Cobertura lograda

El pipeline CI verifica cobertura ≥ 80% en cada commit (`--cov-fail-under=80`). Los tres módulos de prueba cubren:

| Módulo | Tests | Aspectos verificados |
|---|---|---|
| `test_auth.py` | 6 | Login, JWT formato, acceso sin/con token |
| `test_invitados.py` | 8 | CRUD completo, validación, auth |
| `test_presupuesto.py` | 6 | Resumen, configuración, validación |
| `test_mocks.py` | 10 | Mocking de bcrypt, store, JWT |

---

## 2. Pipeline de CI/CD

### Integración Continua — `.github/workflows/ci.yml`

El pipeline CI se ejecuta en cada `push` o `pull_request` a `main`:

```
Commit → GitHub Actions
    │
    ├─ Job 1: test-backend        → PyTest + Cobertura + Allure Report
    │
    ├─ Job 2: postman-tests       → Newman (Postman Collection)
    │      (necesita: test-backend)
    │
    ├─ Job 3: load-test           → k6 (30s ramp + 1min sostenido + 30s ramp down)
    │      (necesita: postman-tests)
    │
    ├─ Job 4: sast-analysis       → Semgrep + SonarCloud
    │      (necesita: test-backend)
    │
    ├─ Job 5: secrets-scan        → Gitleaks (historial completo)
    │
    ├─ Job 6: dependency-check    → Safety (vulnerabilidades en requirements.txt)
    │
    ├─ Job 7: cypress-tests       → Cypress E2E (GUI tests)
    │      (necesita: postman-tests)
    │
    ├─ Job 8: dast-zap            → OWASP ZAP Baseline Scan (DAST)
    │      (necesita: test-backend)
    │
    └─ Job 9: docker-build        → Build imagen + Trivy scan
           (necesita: todos los anteriores)
```

### Despliegue Continuo — `.github/workflows/cd.yml`

Se activa cuando el CI pasa en `main`:

```
CI ✅ en main
    │
    └─ Job 1: build-and-push   → Dockerfile build → DockerHub push
           ↓
    └─ Job 2: deploy           → Simula kubectl set image + comenta en commit
```

### Artefactos generados por el pipeline

| Job | Artefacto | Ruta |
|---|---|---|
| test-backend | Reporte PyTest HTML | `services/reports/pytest-report.html` |
| test-backend | Cobertura XML | `services/reports/coverage.xml` |
| test-backend | Allure Report | `services/reports/allure-report/` |
| postman-tests | Newman HTML | `reports/newman-report.html` |
| load-test | k6 JSON | `reports/k6-results.json` |
| sast-analysis | Semgrep JSON | `reports/semgrep-report.json` |
| dependency-check | Safety JSON | `reports/safety-report.json` |
| cypress-tests | JUnit XML + Screenshots | `tests/gui/cypress/results/` |
| dast-zap | ZAP HTML + JSON | `reports/zap-report.html` |
| docker-build | Trivy SARIF | `trivy-results.sarif` |

---

## 3. DevSecOps

### Herramientas implementadas

| Categoría | Herramienta | Cuándo | Qué detecta |
|---|---|---|---|
| SAST | Semgrep | CI Job 4 | Patrones inseguros en Python |
| SAST | SonarCloud | CI Job 4 | Calidad, bugs, code smells |
| DAST | OWASP ZAP | CI Job 8 | Vulnerabilidades en la API en ejecución |
| Secrets | Gitleaks | CI Job 5 | Secretos en historial git |
| Dependencies | Safety | CI Job 6 | CVEs en dependencias Python |
| Container | Trivy | CI Job 9 | CVEs en imagen Docker |

### Prácticas de seguridad en Kubernetes

| Práctica | Implementación | Archivo |
|---|---|---|
| RBAC | ServiceAccount con mínimo privilegio | `k8s/rbac.yaml` |
| Secrets | SECRET_KEY en `kind: Secret` | `k8s/secret.yaml` |
| Network Policy | Ingress/Egress restringido | `k8s/network-policy.yaml` |
| Pod Security | `runAsNonRoot: true`, `allowPrivilegeEscalation: false` | `k8s/deployment.yaml` |
| Capabilities | `drop: [ALL]` | `k8s/deployment.yaml` |

### Prácticas de seguridad en el código

- **JWT HS256**: tokens firmados con clave secreta, expiración de 3 horas
- **bcrypt**: contraseñas hasheadas con sal antes de almacenarse
- **Dependency injection**: `Depends(get_current_user)` en endpoints protegidos
- **Validación Pydantic**: todos los inputs validados automáticamente con `Field(gt=0)` etc.
- **Usuario no-root en Docker**: `adduser --system appuser` en Dockerfile

---

## 4. Monitoreo y Centralización de Logs

### Stack completo de observabilidad

| Herramienta | Puerto | Función |
|---|---|---|
| Prometheus | :9090 | Recolección de métricas (scraping cada 10s) |
| Grafana | :3000 | Dashboards de métricas + exploración de logs Loki |
| Jaeger | :16686 | Trazabilidad distribuida (OpenTelemetry) |
| Loki | :3100 | Centralización de logs (EFK ligero) |
| Promtail | — | Agente que envía logs Docker a Loki |

### Cómo usar Loki en Grafana

1. Abrir Grafana en `http://localhost:3000`
2. Ir a **Explore** → seleccionar datasource **Loki**
3. Consultar logs del backend: `{container="weddy-backend"}`
4. Filtrar por nivel de error: `{container="weddy-backend"} |= "ERROR"`
