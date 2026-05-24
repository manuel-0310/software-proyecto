# 🤖 Guía Completa para IA — Persona 1: Backend, Pruebas y CI/CD

## Proyecto: Weddy (Wedding Planner)

> **Instrucción para la IA:** Lee todo este documento antes de generar cualquier archivo.
> Tu objetivo es generar TODOS los archivos listados aquí, con código completo y funcional.
> No omitas nada. No uses placeholders como `# TODO` o `...`. Cada archivo debe estar 100% listo para usar.

---

## 🗂️ Contexto del Proyecto

**Nombre:** Weddy — Aplicación de planificación de bodas  
**Arquitectura:** Clean Architecture + Microservicios (Backend separado del Frontend)  
**Backend:** FastAPI (Python) ubicado en `/services/`  
**Frontend:** Flutter (Dart) ubicado en `/client/` ← NO es responsabilidad de Persona 1  
**Repositorio:** [https://github.com/manuel-0310/software-proyecto](https://github.com/manuel-0310/software-proyecto)  

---

## 📁 Estructura actual del backend (ya existe)

```
services/
├── main.py                   ← Punto de entrada FastAPI, CORS, Prometheus, Jaeger
├── requirements.txt          ← Dependencias Python
├── auth/
│   ├── jwt.py                ← Genera/valida tokens JWT (HS256, 3h), credenciales: admin/weddy2024
│   └── dependencies.py       ← Dependencia get_current_user para proteger endpoints
├── routers/
│   ├── auth.py               ← POST /auth/login → devuelve JWT
│   ├── invitados.py          ← CRUD /invitados/ (GET público, POST/PATCH/DELETE protegidos)
│   └── presupuesto.py        ← GET /presupuesto/ (público), POST /presupuesto/configurar (protegido)
├── models/
│   ├── auth.py               ← Pydantic: LoginRequest, TokenResponse
│   ├── invitado.py           ← Pydantic: InvitadoCreate, InvitadoUpdate, InvitadoResponse
│   └── presupuesto.py        ← Pydantic: PresupuestoConfig, PresupuestoResumen
├── data/
│   └── store.py              ← Almacenamiento en memoria (Dict), contador de IDs
└── telemetry/
    └── tracing.py            ← OpenTelemetry → Jaeger en localhost:4318
```

---

## 📡 Endpoints del API (para referencia en todas las pruebas)


| Método | Ruta                      | Auth     | Descripción                   |
| ------ | ------------------------- | -------- | ----------------------------- |
| POST   | `/auth/login`             | ❌        | Login → devuelve Bearer token |
| GET    | `/invitados/`             | ❌        | Listar todos los invitados    |
| POST   | `/invitados/`             | ✅ Bearer | Crear invitado                |
| PATCH  | `/invitados/{id}`         | ✅ Bearer | Actualizar invitado           |
| DELETE | `/invitados/{id}`         | ✅ Bearer | Eliminar invitado             |
| GET    | `/presupuesto/`           | ❌        | Ver resumen de presupuesto    |
| POST   | `/presupuesto/configurar` | ✅ Bearer | Configurar presupuesto        |
| GET    | `/health`                 | ❌        | Health check                  |
| GET    | `/metrics`                | ❌        | Métricas Prometheus           |


**Credenciales:** `username: admin`, `password: weddy2024`  
**Puerto local:** `http://localhost:8000`

---

## ✅ ARCHIVOS A CREAR — Lista completa

### 1. `/services/tests/test_auth.py`

### 2. `/services/tests/test_invitados.py`

### 3. `/services/tests/test_presupuesto.py`

### 4. `/services/tests/__init__.py`

### 5. `/services/tests/conftest.py`

### 6. `/tests/load/load_test.js`

### 7. `/tests/api/weddy.postman_collection.json`

### 8. `/services/Dockerfile`

### 9. `/docker-compose.yml` (raíz del proyecto, reemplaza/complementa el existente)

### 10. `/.github/workflows/ci.yml`

### 11. `/.github/workflows/cd.yml`

### 12. `/sonar-project.properties`

### 13. `/.gitleaks.toml`

### 14. `/services/requirements-dev.txt`

---

## 📄 ESPECIFICACIONES DE CADA ARCHIVO

---

### 📄 1. `/services/tests/conftest.py`

**Propósito:** Configuración compartida para todos los tests de pytest  
**Debe contener:**

- Fixture `client`: instancia de `TestClient` de FastAPI apuntando a `main.app`
- Fixture `auth_token`: hace POST a `/auth/login` con `admin/weddy2024` y retorna el Bearer token como string
- Fixture `auth_headers`: retorna dict `{"Authorization": "Bearer <token>"}` usando `auth_token`
- Importar `from fastapi.testclient import TestClient`
- Importar `from services.main import app` (ajustar path según sea necesario)

---

### 📄 2. `/services/tests/__init__.py`

**Propósito:** Hacer que la carpeta sea un módulo Python  
**Contenido:** Archivo vacío (solo `# tests package`)

---

### 📄 3. `/services/tests/test_auth.py`

**Propósito:** Pruebas unitarias del módulo de autenticación  
**Debe probar:**

- `test_login_exitoso`: POST `/auth/login` con credenciales correctas → status 200 + campo `access_token` en respuesta
- `test_login_credenciales_incorrectas`: POST `/auth/login` con password malo → status 401
- `test_login_usuario_inexistente`: POST `/auth/login` con username que no existe → status 401
- `test_token_tiene_formato_jwt`: el token retornado tiene 3 partes separadas por `.`
- `test_acceso_sin_token`: GET a un endpoint protegido sin header → status 401 o 403
- `test_acceso_con_token_invalido`: header con token falso → status 401 o 403
- Usar fixtures de `conftest.py`

---

### 📄 4. `/services/tests/test_invitados.py`

**Propósito:** Pruebas unitarias CRUD completo de invitados  
**Debe probar:**

- `test_listar_invitados_sin_auth`: GET `/invitados/` sin token → status 200 + lista (puede estar vacía)
- `test_crear_invitado_con_auth`: POST `/invitados/` con token y body `{"nombre": "Juan Test", "email": "juan@test.com", "estado": "pendiente"}` → status 200 o 201 + id en respuesta
- `test_crear_invitado_sin_auth`: POST `/invitados/` sin token → status 401 o 403
- `test_crear_invitado_datos_invalidos`: POST con body incompleto (sin nombre) → status 422
- `test_actualizar_invitado`: crear uno, luego PATCH `/invitados/{id}` con `{"estado": "confirmado"}` → status 200
- `test_eliminar_invitado`: crear uno, luego DELETE `/invitados/{id}` → status 200 o 204
- `test_eliminar_invitado_inexistente`: DELETE `/invitados/99999` → status 404
- `test_invitado_creado_aparece_en_lista`: crear invitado, listar todos, verificar que aparece
- Usar fixtures de `conftest.py`

---

### 📄 5. `/services/tests/test_presupuesto.py`

**Propósito:** Pruebas unitarias del módulo de presupuesto  
**Debe probar:**

- `test_obtener_presupuesto_sin_auth`: GET `/presupuesto/` → status 200
- `test_presupuesto_tiene_campos_requeridos`: la respuesta tiene campos: `presupuesto_maximo`, `costo_total`, `saldo_restante`
- `test_configurar_presupuesto_con_auth`: POST `/presupuesto/configurar` con token y body `{"presupuesto_maximo": 15000, "costo_por_invitado": 75}` → status 200
- `test_configurar_presupuesto_sin_auth`: misma petición sin token → status 401 o 403
- `test_presupuesto_maximo_negativo`: configurar con presupuesto negativo → status 422 o 400
- `test_health_check`: GET `/health` → status 200
- Usar fixtures de `conftest.py`

---

### 📄 6. `/services/requirements-dev.txt`

**Propósito:** Dependencias adicionales solo para desarrollo y pruebas  
**Debe incluir:**

```
pytest==7.4.3
pytest-asyncio==0.21.4
httpx==0.25.2
pytest-cov==4.1.0
pytest-html==4.1.1
```

---

### 📄 7. `/tests/load/load_test.js`

**Propósito:** Prueba de carga con k6 simulando usuarios concurrentes  
**Debe contener:**

- Importar `http` y `check`, `sleep` de k6
- Definir `options` con:
  - `stages`: rampa de 0→10 usuarios en 30s, mantener 10 por 1min, bajar a 0 en 30s
  - `thresholds`: `http_req_duration` < 500ms en 95% de requests, `http_req_failed` < 1%
- Función `setup()`: hacer login y retornar el token
- Función principal `default(data)`:
  - Escenario 1 (sin auth): GET `/invitados/` → verificar status 200
  - Escenario 2 (sin auth): GET `/presupuesto/` → verificar status 200
  - Escenario 3 (con auth): POST `/invitados/` con datos de prueba generados con `Date.now()`
  - `sleep(1)` entre iteraciones
- URL base: `http://localhost:8000`
- Usar `check()` para validar cada respuesta y loguear errores

---

### 📄 8. `/tests/api/weddy.postman_collection.json`

**Propósito:** Colección Postman ejecutable con Newman para CI/CD  
**Debe ser un JSON válido de Postman Collection v2.1 que contenga:**

Carpeta **"Auth":**

- Request `Login Exitoso`: POST `{{baseUrl}}/auth/login`, body JSON `{"username":"admin","password":"weddy2024"}`, test que verifica status 200 y guarda `pm.environment.set("token", pm.response.json().access_token)`
- Request `Login Fallido`: POST `{{baseUrl}}/auth/login`, body JSON con password incorrecto, test que verifica status 401

Carpeta **"Invitados":**

- Request `Listar Invitados`: GET `{{baseUrl}}/invitados/`, test status 200 + respuesta es array
- Request `Crear Invitado`: POST `{{baseUrl}}/invitados/`, header `Authorization: Bearer {{token}}`, body `{"nombre":"Test Newman","email":"newman@test.com","estado":"pendiente"}`, test status 200/201, guarda `pm.environment.set("invitado_id", pm.response.json().id)`
- Request `Actualizar Invitado`: PATCH `{{baseUrl}}/invitados/{{invitado_id}}`, header auth, body `{"estado":"confirmado"}`, test status 200
- Request `Crear Sin Auth`: POST `/invitados/` sin header auth, test status 401 o 403
- Request `Eliminar Invitado`: DELETE `{{baseUrl}}/invitados/{{invitado_id}}`, header auth, test status 200 o 204

Carpeta **"Presupuesto":**

- Request `Ver Presupuesto`: GET `{{baseUrl}}/presupuesto/`, test status 200 + tiene campo `presupuesto_maximo`
- Request `Configurar Presupuesto`: POST `{{baseUrl}}/presupuesto/configurar`, header auth, body `{"presupuesto_maximo":20000,"costo_por_invitado":50}`, test status 200

Carpeta **"Health":**

- Request `Health Check`: GET `{{baseUrl}}/health`, test status 200

**Variables de colección:** `baseUrl = http://localhost:8000`

---

### 📄 9. `/services/Dockerfile`

**Propósito:** Contenerizar el backend FastAPI  
**Debe contener:**

- Base: `python:3.11-slim`
- `WORKDIR /app`
- Copiar `requirements.txt` primero (para cachear la capa de dependencias)
- `RUN pip install --no-cache-dir -r requirements.txt`
- Copiar el resto del código
- Exponer puerto `8000`
- Variable de entorno `PYTHONUNBUFFERED=1`
- `CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]`
- Añadir `HEALTHCHECK` que haga curl a `/health`
- Añadir label con metadata del proyecto

---

### 📄 10. `/docker-compose.yml` (en la raíz del proyecto)

**Propósito:** Orquestar todos los servicios localmente  
**Debe incluir los siguientes servicios:**

`**weddy-backend`:**

- build context: `./services`
- ports: `8000:8000`
- environment: `SECRET_KEY=weddy_secret_key_2024`, `JAEGER_HOST=jaeger`
- depends_on: `jaeger`, `prometheus`
- healthcheck: wget a `/health`
- networks: `weddy-net`

`**prometheus`:**

- image: `prom/prometheus:latest`
- ports: `9090:9090`
- volumes: `./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml`
- networks: `weddy-net`

`**grafana`:**

- image: `grafana/grafana:latest`
- ports: `3000:3000`
- environment: `GF_SECURITY_ADMIN_PASSWORD=admin`
- volumes: `./monitoring/grafana/provisioning:/etc/grafana/provisioning`
- depends_on: prometheus
- networks: `weddy-net`

`**jaeger`:**

- image: `jaegertracing/all-in-one:latest`
- ports: `16686:16686`, `4318:4318`
- networks: `weddy-net`

**networks:** definir `weddy-net` como bridge

---

### 📄 11. `/.github/workflows/ci.yml`

**Propósito:** Pipeline de Integración Continua — se ejecuta en cada push y pull request a `main`  
**Debe tener los siguientes jobs en orden:**

**Job `test-backend`** (runs-on: ubuntu-latest):

1. `actions/checkout@v4`
2. `actions/setup-python@v4` con python-version: '3.11'
3. `pip install -r services/requirements.txt -r services/requirements-dev.txt`
4. `cd services && pytest tests/ -v --cov=. --cov-report=xml --cov-report=html --html=reports/pytest-report.html`
5. Upload artifact: directorio `services/reports/`
6. Verificar que cobertura >= 80% usando `pytest --cov-fail-under=80`

**Job `postman-tests`** (needs: test-backend):

1. checkout
2. setup python + instalar dependencias + levantar backend en background: `cd services && uvicorn main:app &`
3. `sleep 5` para esperar que levante
4. `npm install -g newman newman-reporter-htmlextra`
5. `newman run tests/api/weddy.postman_collection.json --reporters cli,htmlextra --reporter-htmlextra-export reports/newman-report.html`
6. Upload artifact: `reports/newman-report.html`

**Job `load-test`** (needs: postman-tests):

1. checkout
2. instalar k6: `sudo apt-get install k6` (o usar la action oficial de k6)
3. levantar backend en background
4. `sleep 5`
5. `k6 run tests/load/load_test.js --out json=reports/k6-results.json`
6. Upload artifact resultados k6

**Job `sast-analysis`** (needs: test-backend, corre en paralelo con los otros):

1. checkout
2. `actions/setup-java@v3` con java-version: '17' (para SonarQube scanner)
3. Instalar Semgrep: `pip install semgrep`
4. `semgrep --config=auto services/ --json > reports/semgrep-report.json`
5. Usar action de SonarCloud: `sonarsource/sonarcloud-github-action@master`
  - env: `SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}`
6. Upload artifact reporte semgrep

**Job `secrets-scan`** (corre en paralelo):

1. checkout con `fetch-depth: 0` (para ver todo el historial)
2. Usar action: `gitleaks/gitleaks-action@v2`
  - env: `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}`

**Job `dependency-check`** (corre en paralelo):

1. checkout
2. setup python
3. `pip install safety`
4. `safety check -r services/requirements.txt --json > reports/safety-report.json`
5. Upload artifact

**Job `docker-build`** (needs: todos los anteriores):

1. checkout
2. `docker/setup-buildx-action@v3`
3. Build imagen: `docker build -t weddy-backend:${{ github.sha }} ./services`
4. Instalar Trivy: usar `aquasecurity/trivy-action@master`
  - image-ref: `weddy-backend:${{ github.sha }}`
  - format: `table`
  - exit-code: `1` para HIGH y CRITICAL
  - severity: `HIGH,CRITICAL`
5. Upload reporte Trivy

---

### 📄 12. `/.github/workflows/cd.yml`

**Propósito:** Pipeline de Despliegue Continuo — se ejecuta solo en push a `main` cuando CI pasa  
**Debe contener:**

**Trigger:** `on: push: branches: [main]` + `workflow_run` esperando que ci.yml pase

**Job `build-and-push`:**

1. checkout
2. Login a DockerHub: `docker/login-action@v3` con secrets `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN`
3. Build y push: `docker/build-push-action@v5`
  - context: `./services`
  - tags: `${{ secrets.DOCKERHUB_USERNAME }}/weddy-backend:latest` y `weddy-backend:${{ github.sha }}`
  - push: true

**Job `deploy`** (needs: build-and-push):

1. Mensaje de éxito con `echo`
2. Comentario explicando que aquí iría el `kubectl apply` si hubiera cluster configurado
3. Usar `actions/github-script@v7` para crear un comentario en el commit con el resumen del despliegue

---

### 📄 13. `/sonar-project.properties`

**Propósito:** Configuración de SonarCloud para análisis de calidad  
**Debe contener:**

```properties
sonar.projectKey=manuel-0310_software-proyecto
sonar.organization=manuel-0310
sonar.projectName=Weddy - Wedding Planner
sonar.projectVersion=1.0
sonar.sources=services
sonar.exclusions=services/tests/**,**/__pycache__/**,**/*.pyc
sonar.tests=services/tests
sonar.python.coverage.reportPaths=services/coverage.xml
sonar.python.version=3.11
sonar.coverage.exclusions=services/tests/**
```

---

### 📄 14. `/.gitleaks.toml`

**Propósito:** Configuración de Gitleaks para detección de secretos  
**Debe contener:**

- Título del config
- Regla personalizada para detectar strings que parezcan JWT secrets
- Allowlist para ignorar el archivo de tests y el conftest (que tienen credenciales de prueba ficticias como `weddy2024`)
- Ignorar archivos: `*_test.py`, `conftest.py`, `*.postman_collection.json`, `load_test.js`
- Usar `[allowlist]` con paths como regex

---

## 🔧 ARCHIVOS A MODIFICAR

### Modificar: `/services/requirements.txt`

**Agregar al final** las siguientes líneas si no están presentes:

```
prometheus-fastapi-instrumentator>=6.0.0
opentelemetry-api>=1.20.0
opentelemetry-sdk>=1.20.0
opentelemetry-exporter-otlp>=1.20.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
python-multipart>=0.0.6
```

---

## ⚠️ INSTRUCCIONES ESPECIALES PARA LA IA

1. **Genera TODOS los archivos**, no solo algunos. El objetivo es que Persona 1 no tenga que escribir ni una línea.
2. **En los tests de pytest**, asume que el store de datos se resetea entre tests. Si el store es global y persiste entre requests del TestClient, añade un fixture `autouse=True` que limpie el store antes de cada test.
3. **En el collection de Postman**, el JSON debe ser 100% válido. Usa UUIDs reales (puedes generarlos como strings aleatorios de formato `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
4. **En el CI/CD**, todos los `secrets.`* que uses deben estar documentados como comentario en el mismo archivo explicando qué valor poner.
5. **El Dockerfile** debe tener un usuario no-root por seguridad (crear usuario `appuser` y usarlo con `USER appuser`).
6. **Cobertura mínima del 80%**: el job de pytest debe fallar si la cobertura está por debajo. Incluye el flag `--cov-fail-under=80`.
7. **Cada archivo generado** debe tener al inicio un comentario con:
  ```python
   # Proyecto: Weddy - Wedding Planner
   # Entrega 3 - Diseño y Arquitectura de Software
   # Generado para: Persona 1 (Backend, Pruebas y CI/CD)
  ```

---

## 📋 CHECKLIST FINAL (para verificar que todo está completo)

Antes de terminar, verifica que generaste:

- `services/tests/__init__.py`
- `services/tests/conftest.py`
- `services/tests/test_auth.py`
- `services/tests/test_invitados.py`
- `services/tests/test_presupuesto.py`
- `services/requirements-dev.txt`
- `tests/load/load_test.js`
- `tests/api/weddy.postman_collection.json`
- `services/Dockerfile`
- `docker-compose.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/cd.yml`
- `sonar-project.properties`
- `.gitleaks.toml`
- Revisión de `services/requirements.txt`

---

---

*Documento generado para el curso Diseño y Arquitectura de Software — Entrega 3*