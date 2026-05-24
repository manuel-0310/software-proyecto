# Guía de Ejecución — Weddy C2

## ¿Qué es este proyecto?

Weddy es una plataforma de gestión de bodas compuesta por tres partes:


| Componente                         | Tecnología                    | Qué hace                                                            |
| ---------------------------------- | ----------------------------- | ------------------------------------------------------------------- |
| **Backend** (`services/`)          | FastAPI + Python 3.11         | Servidor REST que gestiona invitados, presupuesto y autenticación   |
| **App móvil** (`client/`)          | Flutter                       | App que consume el backend y tiene Circuit Breaker para resiliencia |
| **Observabilidad** (`monitoring/`) | Prometheus + Grafana + Jaeger | Monitorea el comportamiento del backend en tiempo real              |


> **Nota importante:** esta guía incluye instrucciones para **macOS** y **Windows**. Cada sección indica claramente cuál comando usar según el sistema operativo.

---

## Requisitos previos

Instala todo esto antes de continuar. Cada herramienta tiene un enlace de descarga oficial.

### 1. Python 3.11

**macOS:**

```bash
brew install python@3.11
```

**Windows:**  
Descarga el instalador desde: [https://www.python.org/downloads/release/python-3119/](https://www.python.org/downloads/release/python-3119/)  
Durante la instalación, marca la casilla **"Add Python to PATH"**.

Verifica en ambos sistemas:

```bash
python --version
# Debe mostrar: Python 3.11.x
```

---

### 2. Flutter

Descarga e instala según tu sistema:

- **macOS:** [https://docs.flutter.dev/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)
- **Windows:** [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)

Verifica:

```bash
flutter doctor
```

No es necesario que todo esté en verde — solo que Flutter esté instalado.

---

### 3. Docker Desktop

Docker es necesario para levantar Jaeger (trazabilidad distribuida).

Descarga desde: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

- Elige **Apple Silicon** si tienes Mac con chip M1/M2/M3
- Elige **Windows** si usas Windows

Después de instalar, **abre Docker Desktop** y espera a que aparezca el ícono de la ballena en la barra de tareas. Docker debe estar corriendo antes de continuar.

---

## Configuración inicial (solo la primera vez)

### Paso 1 — Clona el repositorio

```bash
git clone <URL-del-repositorio>
cd software-proyecto
```

---

### Paso 2 — Configura el backend

**macOS:**

```bash
cd services
/opt/homebrew/bin/python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Windows** (en PowerShell o CMD):

```bash
cd services
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

✅ Listo cuando veas que todas las dependencias se instalan sin errores.

---

### Paso 3 — Instala dependencias de Flutter

```bash
cd client
flutter pub get
```

---

## Ejecución del proyecto

Para correr el proyecto completo necesitas **3 terminales abiertas al mismo tiempo**.

---

### Terminal 1 — Backend

**macOS:**

```bash
cd services
source .venv/bin/activate
JAEGER_ENABLED=true uvicorn main:app --host 0.0.0.0
```

**Windows** (CMD):

```cmd
cd services
.venv\Scripts\activate
set JAEGER_ENABLED=true && uvicorn main:app --host 0.0.0.0
```

✅ Listo cuando veas:

```
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

### Terminal 2 — Observabilidad (Prometheus, Grafana, Jaeger)

**macOS (ya que esta configurado para este OS):**

```bash
brew services start prometheus
brew services start grafana
cd monitoring
docker compose up -d
```



✅ URLs disponibles:


| Herramienta | URL                                                      | Credenciales      |
| ----------- | -------------------------------------------------------- | ----------------- |
| Backend API | [http://localhost:8000/docs](http://localhost:8000/docs) | —                 |
| Prometheus  | [http://localhost:9090](http://localhost:9090)           | —                 |
| Grafana     | [http://localhost:3000](http://localhost:3000)           | admin / weddy2024 |
| Jaeger      | [http://localhost:16686](http://localhost:16686)         | —                 |


---

### Terminal 2 alternativa — Obtén el token JWT

El backend requiere autenticación para operaciones de escritura. Obtén el token así:

**macOS / Windows (con curl):**

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"weddy2024\"}"
```

También puedes usar la documentación interactiva del backend:

1. Abre [http://localhost:8000/docs](http://localhost:8000/docs)
2. Busca `POST /auth/login`
3. Haz clic en **Try it out**
4. Ingresa usuario `admin` y contraseña `weddy2024`
5. Copia el `access_token` de la respuesta

Luego pega el token en `client/lib/data/remote/api_client.dart` línea 27:

```dart
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

> El token dura **3 horas**. Si vence, repite este paso.

---

### Terminal 3 — App Flutter (en celular físico)

#### Obtén la IP de tu computador

**macOS:**

```bash
ipconfig getifaddr en0
```

**Windows:**

```cmd
ipconfig
```

Busca la línea que dice **Dirección IPv4** bajo tu adaptador WiFi. Ejemplo: `192.168.1.45`

#### Actualiza la IP en el código

Abre `client/lib/data/remote/api_client.dart` línea 10:

```dart
static const String baseUrl = 'http://TU_IP_AQUI:8000';
// Ejemplo: 'http://192.168.1.45:8000'
```

#### Conecta tu celular

#### Verifica que el celular fue detectado

```bash
flutter devices
```

Debe aparecer tu celular en la lista.

#### Corre la app

```bash
cd client
flutter run
```

> **Importante:** el celular y el computador deben estar conectados a la **misma red WiFi**.

---

## Guía de uso — ejemplo completo

### 1. Agregar un invitado

1. Abre la app → pantalla **Invitados**
2. Toca **"+ Agregar"**
3. Llena: Nombre `Juan`, Apellido `Pérez`, Correo `juan@email.com`
4. Toca **Guardar**

En la Terminal 1 del backend verás:

```
POST /invitados/ HTTP/1.1" 201 Created
GET  /invitados/ HTTP/1.1" 200 OK
```

---

### 2. Cambiar estado de un invitado

1. Toca sobre el invitado en la lista
2. Cambia su estado a **Confirmado**

En la Terminal 1:

```
PATCH /invitados/1/estado HTTP/1.1" 200 OK
```

---

### 3. Ver el presupuesto

1. Ve a la pantalla **Presupuesto**
2. Verás el costo calculado: **$50 por invitado confirmado** sobre un límite de **$20,000**

---

### 4. Probar la resiliencia (Circuit Breaker)

1. Para el backend en Terminal 1 con `Ctrl+C`
2. En la app, desliza hacia abajo para recargar — repite **3 veces**
3. Al tercer intento aparece un **banner naranja**: *"Servicio no disponible. Mostrando datos en caché."*
4. Los datos siguen visibles aunque el backend esté caído
5. Vuelve a levantar el backend
6. Toca **"Reintentar"** en el banner — la app reconecta

---

### 5. Ver métricas en Prometheus

1. Abre [http://localhost:9090](http://localhost:9090)
2. Escribe en el buscador: `http_requests_total{job="weddy-api"}`
3. Presiona **Execute**
4. Verás los contadores de cada endpoint

---

### 6. Ver gráficas en Grafana

1. Abre [http://localhost:3000](http://localhost:3000) (admin / weddy2024)
2. Ve a **Dashboards**
3. En el panel, selecciona la métrica `http_requests_total` con filtro `job = weddy-api`
4. Verás la gráfica actualizándose en tiempo real

---

### 7. Ver trazas en Jaeger

1. Abre [http://localhost:16686](http://localhost:16686)
2. En **Service** selecciona `weddy-api`
3. Presiona **Find Traces**
4. Verás cada request individual con su tiempo de procesamiento

---


