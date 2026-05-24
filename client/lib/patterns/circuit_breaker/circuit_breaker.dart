// Implementación del patrón Circuit Breaker para proteger las llamadas HTTP
// de la app Weddy (Servicio Consumidor) hacia la Weddy API (Servicio Proveedor).
//
// Estados del circuito:
//   CLOSED   → operación normal, las llamadas pasan.
//   OPEN     → circuito abierto tras [failureThreshold] fallos consecutivos.
//              Las llamadas fallan rápido sin llegar al backend.
//              El circuito se mantiene abierto durante [resetTimeout].
//   HALF_OPEN → pasado [resetTimeout], se permite UNA llamada de prueba.
//              Si tiene éxito → CLOSED. Si falla → OPEN de nuevo.
//
// Uso típico:
//   final cb = CircuitBreaker(name: 'invitados');
//   final resultado = await cb.execute(() => ApiClient.get('/invitados/'));

enum CircuitState { closed, open, halfOpen }

/// Excepción lanzada cuando el circuito está OPEN y no hay caché disponible.
class CircuitBreakerException implements Exception {
  final String message;
  const CircuitBreakerException(this.message);

  @override
  String toString() => message;
}

class CircuitBreaker {
  final String name;

  /// Número de fallos consecutivos necesarios para abrir el circuito.
  final int failureThreshold;

  /// Tiempo que el circuito permanece OPEN antes de intentar HALF_OPEN.
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _openedAt;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(seconds: 30),
  });

  // ── Estado observable ────────────────────────────────────────────────────

  CircuitState get state => _state;
  bool get isOpen => _state == CircuitState.open;
  bool get isClosed => _state == CircuitState.closed;
  bool get isHalfOpen => _state == CircuitState.halfOpen;
  int get failureCount => _failureCount;

  /// Segundos restantes hasta que el circuito intente HALF_OPEN (0 si ya pasó).
  int get secondsUntilRetry {
    if (_state != CircuitState.open || _openedAt == null) return 0;
    final elapsed = DateTime.now().difference(_openedAt!);
    final remaining = resetTimeout - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  // ── Ejecución protegida ──────────────────────────────────────────────────

  /// Ejecuta [action] aplicando la lógica del Circuit Breaker.
  ///
  /// Lanza [CircuitBreakerException] si el circuito está OPEN y aún no
  /// ha pasado el [resetTimeout].
  /// Relanza la excepción original si la acción falla en estado CLOSED/HALF_OPEN.
  Future<T> execute<T>(Future<T> Function() action) async {
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitState.halfOpen;
      } else {
        throw CircuitBreakerException(
          'El servicio "$name" no está disponible. '
          'Reintentando en $secondsUntilRetry s.',
        );
      }
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      // No contamos CircuitBreakerException como un fallo adicional.
      if (e is CircuitBreakerException) rethrow;
      _onFailure();
      rethrow;
    }
  }

  // ── Transiciones de estado ───────────────────────────────────────────────

  void _onSuccess() {
    _failureCount = 0;
    _openedAt = null;
    _state = CircuitState.closed;
  }

  void _onFailure() {
    _failureCount++;
    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
      _openedAt = DateTime.now();
    }
  }

  bool _shouldAttemptReset() {
    return _openedAt != null &&
        DateTime.now().difference(_openedAt!) >= resetTimeout;
  }

  /// Reinicia el circuito manualmente (útil para tests o botón "Reintentar").
  void reset() {
    _failureCount = 0;
    _openedAt = null;
    _state = CircuitState.closed;
  }

  @override
  String toString() =>
      'CircuitBreaker($name: $_state, fallos: $_failureCount/$failureThreshold)';
}
