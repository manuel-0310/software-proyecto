import '../../patterns/circuit_breaker/circuit_breaker.dart';
import 'api_client.dart';

/// Resumen de presupuesto tal como lo devuelve la Weddy API.
class PresupuestoResumenRemoto {
  final double presupuestoTotal;
  final double costoPorInvitadoConfirmado;
  final int totalInvitadosConfirmados;
  final double costoInvitados;
  final double costoTotal;
  final double saldoRestante;
  final bool dentroDelPresupuesto;
  final double porcentajeUtilizado;

  const PresupuestoResumenRemoto({
    required this.presupuestoTotal,
    required this.costoPorInvitadoConfirmado,
    required this.totalInvitadosConfirmados,
    required this.costoInvitados,
    required this.costoTotal,
    required this.saldoRestante,
    required this.dentroDelPresupuesto,
    required this.porcentajeUtilizado,
  });

  factory PresupuestoResumenRemoto.fromJson(Map<String, dynamic> json) {
    return PresupuestoResumenRemoto(
      presupuestoTotal: (json['presupuesto_total'] as num).toDouble(),
      costoPorInvitadoConfirmado:
          (json['costo_por_invitado_confirmado'] as num).toDouble(),
      totalInvitadosConfirmados:
          (json['total_invitados_confirmados'] as num).toInt(),
      costoInvitados: (json['costo_invitados'] as num).toDouble(),
      costoTotal: (json['costo_total'] as num).toDouble(),
      saldoRestante: (json['saldo_restante'] as num).toDouble(),
      dentroDelPresupuesto: json['dentro_del_presupuesto'] as bool,
      porcentajeUtilizado: (json['porcentaje_utilizado'] as num).toDouble(),
    );
  }
}

/// Datasource remoto para presupuesto con Circuit Breaker y caché de último estado.
///
/// Circuit Breaker:
///   - Abre tras 3 fallos consecutivos, espera 30 s antes de HALF_OPEN.
///   - [obtenerResumen] retorna la última caché exitosa si el circuito está abierto.
///   - [configurar] lanza [CircuitBreakerException] si el circuito está abierto.
class PresupuestoRemoteDatasource {
  final CircuitBreaker _cb = CircuitBreaker(
    name: 'presupuesto',
    failureThreshold: 3,
    resetTimeout: const Duration(seconds: 30),
  );

  /// Último resumen exitoso, usado como fallback cuando el circuito está abierto.
  PresupuestoResumenRemoto? _cache;

  // ── Estado del circuito ──────────────────────────────────────────────────

  CircuitState get circuitState => _cb.state;
  bool get circuitoAbierto => _cb.isOpen;
  int get segundosParaReintento => _cb.secondsUntilRetry;

  void resetCircuito() => _cb.reset();

  // ── Lectura (pública, sin token) ─────────────────────────────────────────

  /// Obtiene el resumen de presupuesto desde el backend.
  /// Si el circuito está OPEN, retorna la caché en lugar de fallar.
  Future<PresupuestoResumenRemoto> obtenerResumen() async {
    try {
      final resumen = await _cb.execute(() async {
        final data = await ApiClient.get('/presupuesto/');
        return PresupuestoResumenRemoto.fromJson(data as Map<String, dynamic>);
      });
      _cache = resumen; // actualiza caché con datos frescos
      return resumen;
    } on CircuitBreakerException {
      if (_cache != null) return _cache!; // degradación elegante
      rethrow;
    }
  }

  // ── Escritura (protegida con JWT) ────────────────────────────────────────
  // TODO(JWT): Este endpoint requiere Bearer token. Ver ApiClient._authHeaders.

  Future<PresupuestoResumenRemoto> configurar({
    required double presupuestoTotal,
    required double costoPorInvitadoConfirmado,
  }) async {
    final body = {
      'presupuesto_total': presupuestoTotal,
      'costo_por_invitado_confirmado': costoPorInvitadoConfirmado,
    };
    return _cb.execute(() async {
      final data = await ApiClient.post('/presupuesto/configurar', body);
      return PresupuestoResumenRemoto.fromJson(data as Map<String, dynamic>);
    });
  }
}
