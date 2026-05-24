import '../../enums/estado_invitado.dart';
import '../../models/invitado.dart';
import '../../patterns/circuit_breaker/circuit_breaker.dart';
import 'api_client.dart';

/// Datasource remoto para invitados con Circuit Breaker y caché de último estado.
///
/// Mapeo Flutter ↔ Backend:
///   Flutter nombre + apellido  →  Backend nombre (concatenado con espacio)
///   Flutter correo             →  Backend email
///   Flutter mesaAsignada       →  Backend mesa
///   Flutter rechazado          →  Backend cancelado
///
/// Circuit Breaker:
///   - Se abre tras 3 fallos consecutivos de red/timeout.
///   - Permanece abierto 30 segundos antes de intentar HALF_OPEN.
///   - En estado OPEN, [obtenerTodos] retorna la caché en lugar de fallar.
///   - Los métodos de escritura lanzan [CircuitBreakerException] si el circuito está abierto.
class InvitadoRemoteDatasource {
  final CircuitBreaker _cb = CircuitBreaker(
    name: 'invitados',
    failureThreshold: 3,
    resetTimeout: const Duration(seconds: 30),
  );

  /// Última lista exitosa, usada como fallback cuando el circuito está abierto.
  List<Invitado> _cache = [];

  // ── Estado del circuito (expuesto para los controladores) ────────────────

  CircuitState get circuitState => _cb.state;
  bool get circuitoAbierto => _cb.isOpen;
  int get fallosConsecutivos => _cb.failureCount;
  int get segundosParaReintento => _cb.secondsUntilRetry;

  /// Permite reiniciar el circuito manualmente (ej. botón "Reintentar" en la UI).
  void resetCircuito() => _cb.reset();

  // ── Lectura (pública, sin token) ─────────────────────────────────────────

  /// Obtiene todos los invitados.
  /// Si el circuito está OPEN, retorna la caché en lugar de fallar.
  Future<List<Invitado>> obtenerTodos() async {
    try {
      final lista = await _cb.execute(() async {
        final data = await ApiClient.get('/invitados/') as List<dynamic>;
        return data
            .map((json) => _fromJson(json as Map<String, dynamic>))
            .toList();
      });
      _cache = lista; // actualiza caché con datos frescos
      return lista;
    } on CircuitBreakerException {
      // Degradación elegante: retorna caché si existe.
      if (_cache.isNotEmpty) return List.unmodifiable(_cache);
      rethrow;
    }
  }

  Future<Invitado?> obtenerPorId(String id) async {
    try {
      return await _cb.execute(() async {
        final data = await ApiClient.get('/invitados/$id');
        return _fromJson(data as Map<String, dynamic>);
      });
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    } on CircuitBreakerException {
      // Busca en caché local si el circuito está abierto.
      try {
        return _cache.firstWhere((inv) => inv.id == id);
      } catch (_) {
        rethrow; // relanza CircuitBreakerException si no está en caché
      }
    }
  }

  // ── Escritura (protegida con JWT) ────────────────────────────────────────
  // TODO(JWT): Los métodos post/patch/delete usan ApiClient._authHeaders.
  //            Asegúrate de llamar ApiClient.setToken(token) tras el login.
  //
  // Nota de resiliencia: si el circuito está OPEN, estas operaciones fallan
  // rápido con [CircuitBreakerException] para no acumular peticiones pendientes.

  Future<Invitado> crear({
    required String nombre,
    required String apellido,
    required String correo,
    String? telefono,
    int? mesaAsignada,
  }) async {
    final body = {
      'nombre': '${nombre.trim()} ${apellido.trim()}'.trim(),
      'email': correo.isEmpty ? null : correo,
      'mesa': mesaAsignada,
      'estado': 'pendiente',
    };
    return _cb.execute(() async {
      final data = await ApiClient.post('/invitados/', body);
      return _fromJson(data as Map<String, dynamic>);
    });
  }

  Future<Invitado> actualizarEstado(
      String id, EstadoInvitado nuevoEstado) async {
    final body = {'estado': _estadoToBackend(nuevoEstado)};
    return _cb.execute(() async {
      final data = await ApiClient.patch('/invitados/$id/estado', body);
      return _fromJson(data as Map<String, dynamic>);
    });
  }

  Future<void> eliminar(String id) async {
    await _cb.execute(() => ApiClient.delete('/invitados/$id'));
  }

  // ── Mapeo JSON ───────────────────────────────────────────────────────────

  Invitado _fromJson(Map<String, dynamic> json) {
    final fullName = (json['nombre'] as String? ?? '').trim();
    final spaceIdx = fullName.indexOf(' ');
    final nombre =
        spaceIdx == -1 ? fullName : fullName.substring(0, spaceIdx);
    final apellido =
        spaceIdx == -1 ? '' : fullName.substring(spaceIdx + 1);

    return Invitado(
      id: json['id'].toString(),
      nombre: nombre,
      apellido: apellido,
      correo: json['email'] as String? ?? '',
      mesaAsignada: json['mesa'] as int?,
      estado: _estadoFromBackend(json['estado'] as String? ?? 'pendiente'),
    );
  }

  String _estadoToBackend(EstadoInvitado estado) {
    switch (estado) {
      case EstadoInvitado.pendiente:
        return 'pendiente';
      case EstadoInvitado.confirmado:
        return 'confirmado';
      case EstadoInvitado.rechazado:
        return 'cancelado'; // Backend usa "cancelado" para rechazado
    }
  }

  EstadoInvitado _estadoFromBackend(String estado) {
    switch (estado) {
      case 'confirmado':
        return EstadoInvitado.confirmado;
      case 'cancelado':
        return EstadoInvitado.rechazado; // Backend "cancelado" → Flutter "rechazado"
      default:
        return EstadoInvitado.pendiente;
    }
  }
}
