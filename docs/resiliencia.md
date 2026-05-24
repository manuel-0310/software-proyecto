# Resiliencia del Sistema — Weddy

## 1. ¿Qué es la resiliencia en software?

La resiliencia es la capacidad de un sistema de **continuar funcionando de manera controlada ante fallos parciales**. En arquitecturas orientadas a servicios, la comunicación entre componentes puede fallar en cualquier momento por razones de red, sobrecarga del servidor o caídas inesperadas. Sin mecanismos de resiliencia, un fallo en el backend deja la app completamente inutilizable.

---

## 2. Patrones de resiliencia investigados

### Circuit Breaker — **implementado en Weddy**

Actúa como un interruptor eléctrico: cuando detecta fallos repetidos, "abre el circuito" y deja de enviar peticiones que probablemente fallarán, permitiendo que el sistema se recupere.

**Estados del Circuit Breaker:**

```
CLOSED ──(3 fallos)──► OPEN ──(30 segundos)──► HALF-OPEN
  ▲                                                  │
  └──────────────(éxito)────────────────────────────┘
```

- **CLOSED:** funcionamiento normal, las peticiones fluyen al backend
- **OPEN:** circuito abierto, las peticiones no se envían, se devuelven datos en caché
- **HALF-OPEN:** estado de prueba, se intenta una petición para verificar si el backend recuperó

### Retry (Reintentos)

Reintenta automáticamente una operación fallida N veces antes de declarar error. Útil para fallos transitorios de red que se resuelven solos en milisegundos.

### Timeout

Establece un tiempo máximo de espera. Si el servicio no responde en ese tiempo, la operación falla rápido en lugar de bloquear indefinidamente al usuario.

### Fallback 

Define una respuesta alternativa cuando la operación principal falla. Puede ser un valor por defecto, datos cacheados o una respuesta simplificada.

---

## 3. Patrón implementado: Circuit Breaker + Fallback

Se implementó **Circuit Breaker con Fallback basado en caché** en la capa de datasources remotos del cliente Flutter.

### Configuración implementada

```dart
// client/lib/patterns/circuit_breaker/circuit_breaker.dart
CircuitBreaker(
  name: 'invitados',
  failureThreshold: 3,                    // abre tras 3 fallos consecutivos
  resetTimeout: Duration(seconds: 30),    // intenta reconectar a los 30 segundos
)
```

### Lógica de estados

```
Petición al backend
        │
        ▼
¿Circuito OPEN?
   SÍ ──► ¿Pasaron 30 segundos?
              SÍ ──► Pasa a HALF-OPEN → intenta petición
              NO ──► Lanza CircuitBreakerException → devuelve caché
   NO ──► Envía petición al backend
              │
              ├── Éxito ──► resetea contador de fallos → CLOSED
              └── Fallo ──► incrementa contador
                                │
                                └── ¿Contador >= 3? ──► abre circuito → OPEN
```

### Fallback con caché

Cuando el circuito se abre, en lugar de mostrar un error vacío, la app devuelve los últimos datos que tenía guardados:

```dart
// client/lib/data/remote/invitado_remote_datasource.dart
Future<List<Invitado>> obtenerTodos() async {
  try {
    final data = await _cb.execute(() => ApiClient.get('/invitados/'));
    _cache = _mapearLista(data);   // actualiza caché en cada éxito
    return _cache;
  } on CircuitBreakerException {
    if (_cache.isNotEmpty) return _cache;   // fallback: devuelve caché
    rethrow;
  }
}
```

---

## 4. Dónde se aplica en el sistema

El patrón está aplicado en **dos datasources remotos**, cubriendo las dos funcionalidades principales:


| Datasource                  | Archivo                                                     | Endpoints protegidos                                                                            |
| --------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| InvitadoRemoteDatasource    | `client/lib/data/remote/invitado_remote_datasource.dart`    | `GET /invitados/`, `POST /invitados/`, `PATCH /invitados/{id}/estado`, `DELETE /invitados/{id}` |
| PresupuestoRemoteDatasource | `client/lib/data/remote/presupuesto_remote_datasource.dart` | `GET /presupuesto/`, `POST /presupuesto/configurar`                                             |


Cada datasource tiene su propio CircuitBreaker independiente, lo que significa que un fallo en invitados no afecta al circuito de presupuesto y viceversa.

---

## 5. Cómo se evidencia en funcionamiento

### Escenario de prueba paso a paso

**Preparación:**

1. Levantar el backend (`uvicorn main:app --host 0.0.0.0`)
2. Abrir la app en la pantalla de Invitados
3. Agregar al menos un invitado para que quede en caché

**Inducción del fallo:**

1. Detener el backend (`Ctrl+C`)
2. En la app, deslizar hacia abajo para recargar → **fallo 1** (circuito CLOSED, sin cambio visible)
3. Deslizar de nuevo → **fallo 2** (circuito CLOSED, sin cambio visible)
4. Deslizar de nuevo → **fallo 3** → **circuito se ABRE**

**Resultado esperado:**

- Aparece un banner naranja con el mensaje: *"Servicio no disponible. Mostrando datos en caché."*
- Los invitados siguen visibles (datos del caché)
- La app no se cierra ni se bloquea

**Recuperación:**

1. Volver a levantar el backend
2. Esperar 30 segundos (HALF-OPEN automático) o tocar **"Reintentar"**
3. La app reconecta → banner desaparece → datos frescos del backend

### Tabla de comportamientos observados


| Escenario                        | Estado del circuito | Comportamiento de la app                |
| -------------------------------- | ------------------- | --------------------------------------- |
| Backend activo                   | CLOSED              | Carga datos normalmente                 |
| 1 o 2 fallos                     | CLOSED              | Muestra error puntual, sigue intentando |
| 3 fallos consecutivos            | OPEN                | Banner naranja + datos en caché         |
| Circuito abierto + backend caído | OPEN                | App usable con datos cacheados          |
| 30 segundos después              | HALF-OPEN           | Intenta una petición de prueba          |
| Backend vuelve + HALF-OPEN       | CLOSED              | Reconecta, banner desaparece            |


---

## 6. Nota sobre la pérdida de datos al reconectar

Al reiniciar el backend, los datos en memoria RAM se pierden porque el sistema no usa base de datos persistente. Esto es independiente del Circuit Breaker: el patrón funciona correctamente (maneja el fallo, muestra caché, reconecta), pero al reconectar con un backend vacío la lista aparece vacía.

En un entorno de producción con base de datos, esta situación no ocurriría — el backend reiniciaría conservando todos los datos.

---

## 7. Conclusión

La implementación del patrón Circuit Breaker con Fallback permite que Weddy mantenga una experiencia de usuario aceptable incluso cuando el backend está caído. El usuario siempre ve datos (aunque sean cacheados), nunca una pantalla en blanco, y tiene control sobre cuándo reintentar la conexión. Esto cumple el requisito de resiliencia exigido y demuestra un manejo profesional de fallos en arquitecturas orientadas a servicios.