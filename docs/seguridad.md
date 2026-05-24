# Seguridad del Sistema — Weddy

## 1. Mecanismo implementado

Weddy implementa seguridad básica mediante **autenticación basada en JWT (JSON Web Token)** con el algoritmo de firma **HS256**.

JWT es un estándar abierto (RFC 7519) ampliamente usado en la industria para transmitir información de autenticación de forma segura entre servicios. Un token JWT contiene tres partes codificadas en Base64: encabezado, payload y firma digital.

---

## 2. ¿Cómo funciona en Weddy?

### Flujo de autenticación

```
App Flutter                        Weddy API
    │                                  │
    │  POST /auth/login                │
    │  {"username":"admin",            │
    │   "password":"weddy2024"}        │
    │ ──────────────────────────────► │
    │                                  │  Verifica credenciales
    │                                  │  Genera token JWT firmado
    │                                  │  (válido por 3 horas)
    │  200 OK                          │
    │  {"access_token": "eyJ..."}      │
    │ ◄────────────────────────────── │
    │                                  │
    │  POST /invitados/                │
    │  Authorization: Bearer eyJ...    │
    │ ──────────────────────────────► │
    │                                  │  Valida firma del token
    │                                  │  Verifica que no haya expirado
    │                                  │  Procesa la petición
    │  201 Created                     │
    │ ◄────────────────────────────── │
```

### Generación del token (`services/auth/jwt.py`)

```python
SECRET_KEY = "weddy-dev-secret-key-cambiar-en-produccion"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 180   # 3 horas

def create_access_token(subject: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
```

El token incluye:
- `sub`: identificador del usuario (username)
- `exp`: timestamp de expiración
- Firma HMAC-SHA256 con la clave secreta del servidor

### Validación del token (`services/auth/dependencies.py`)

En cada endpoint protegido, FastAPI ejecuta automáticamente la dependencia `get_current_user` que:
1. Extrae el token del header `Authorization: Bearer <token>`
2. Verifica la firma con la clave secreta
3. Verifica que el token no haya expirado
4. Si algo falla → responde `401 Unauthorized` automáticamente

---

## 3. Endpoints protegidos

La estrategia de seguridad distingue entre operaciones de **lectura** (públicas) y **escritura** (protegidas):

| Endpoint | Método | Acceso | Justificación |
|---|---|---|---|
| `/auth/login` | POST | Público | Punto de entrada para obtener el token |
| `/invitados/` | GET | Público | Consultar la lista no requiere autenticación |
| `/invitados/` | POST | **Protegido** | Crear invitados modifica el estado del sistema |
| `/invitados/{id}/estado` | PATCH | **Protegido** | Modificar datos requiere autenticación |
| `/invitados/{id}` | DELETE | **Protegido** | Eliminar datos requiere autenticación |
| `/presupuesto/` | GET | Público | Consultar el presupuesto no requiere autenticación |
| `/presupuesto/configurar` | POST | **Protegido** | Cambiar la configuración financiera requiere autenticación |

### Implementación en el router (`services/routers/invitados.py`)

```python
from auth.dependencies import get_current_user

@router.post("/", status_code=201)
def crear_invitado(
    body: InvitadoCreate,
    user: str = Depends(get_current_user)   # ← requiere token válido
):
    ...
```

La dependencia `Depends(get_current_user)` hace que FastAPI valide automáticamente el token antes de ejecutar la función.

---

## 4. Evidencia de funcionamiento

### Caso 1 — Sin token (debe fallar)
```bash
curl -X POST http://localhost:8000/invitados/ \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Juan Pérez", "email": "juan@email.com"}'
```
**Respuesta:** `403 Forbidden`

### Caso 2 — Con token válido (debe funcionar)
```bash
# Obtener token
curl -X POST http://localhost:8000/auth/login \
  -d '{"username":"admin","password":"weddy2024"}'
# → {"access_token": "eyJ..."}

# Usar token
curl -X POST http://localhost:8000/invitados/ \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Juan Pérez", "email": "juan@email.com"}'
```
**Respuesta:** `201 Created + JSON del invitado creado`

### Caso 3 — Con token vencido (debe fallar)
Si han pasado más de 3 horas desde que se generó el token:
**Respuesta:** `401 Unauthorized`

### Resumen de respuestas

| Situación | Código de respuesta |
|---|---|
| Sin token | 403 Forbidden |
| Token inválido o manipulado | 401 Unauthorized |
| Token expirado | 401 Unauthorized |
| Token válido | 2xx (según la operación) |

---

## 5. Consideraciones de seguridad

- **Clave secreta:** en el proyecto académico está hardcodeada por simplicidad. En producción debe almacenarse en variables de entorno o un gestor de secretos (AWS Secrets Manager, HashiCorp Vault)
- **HTTPS:** en producción toda comunicación debe ir sobre HTTPS para que el token no viaje en texto plano
- **Almacenamiento del token:** en la app académica el token está hardcodeado en el código. En producción se guardaría con `flutter_secure_storage` (usa el Keychain de iOS / Keystore de Android — cifrado a nivel de hardware)
- **Renovación automática:** en producción la app haría login automáticamente al detectar un token vencido, sin intervención del usuario

---

## 6. Conclusión

La seguridad implementada en Weddy cumple el requisito de la rúbrica: autenticación JWT, validación de tokens y protección de al menos dos endpoints relevantes. Las operaciones de escritura (crear, modificar y eliminar invitados, configurar presupuesto) requieren token válido, mientras que las de lectura son públicas. Esto refleja un modelo de control de acceso coherente con arquitecturas REST modernas.
