// Archivo para el controlador de presupuesto (Servicio Consumidor → Weddy API).

import '../data/remote/presupuesto_remote_datasource.dart';
import '../models/presupuesto.dart';
import '../patterns/circuit_breaker/circuit_breaker.dart';
import '../services/invitado_service.dart';
import '../services/proveedor_service.dart';

class PresupuestoController {

// Variable para presupuesto remoto datasource (con Circuit Breaker incorporado).
  final PresupuestoRemoteDatasource _presupuestoRemoto;

// Variable para invitado servicio (caché local, poblada por InvitadoController).
  final InvitadoService _invitadoService;

// Variable para proveedor servicio (permanece local).
  final ProveedorService _proveedorService;

// Variable para presupuesto.
  Presupuesto? _presupuesto;
  Presupuesto? get presupuesto => _presupuesto;

// Estado del Circuit Breaker visible para la UI.
  bool _circuitoAbierto = false;
  bool get circuitoAbierto => _circuitoAbierto;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

// Variable para on cambio.
  final void Function()? onCambio;

  PresupuestoController({
    required PresupuestoRemoteDatasource presupuestoRemoto,
    required InvitadoService invitadoService,
    required ProveedorService proveedorService,
    this.onCambio,
  })  : _presupuestoRemoto = presupuestoRemoto,
        _invitadoService = invitadoService,
        _proveedorService = proveedorService;

  // ── Recálculo con resiliencia ────────────────────────────────────────────
  // TODO(JWT): POST /presupuesto/configurar está protegido con JWT.
  //            Si implementas la configuración desde la app, pasa el token en ApiClient.

  /// Consulta GET /presupuesto/ y construye el [Presupuesto] combinando datos
  /// del backend con los proveedores locales.
  /// Si el circuito está OPEN, usa la caché del datasource (degradación elegante).
  Future<void> recalcular() async {
    try {
      final remoto = await _presupuestoRemoto.obtenerResumen();
      final invitadosLocales = _invitadoService.obtenerTodos();
      final proveedores = _proveedorService.obtenerTodos();

      _presupuesto = Presupuesto(
        presupuestoMaximo: remoto.presupuestoTotal,
        costoPorInvitadoConfirmado: remoto.costoPorInvitadoConfirmado,
        invitados: invitadosLocales,
        proveedores: proveedores,
      );
      _circuitoAbierto = false;
      _mensajeError = null;
    } on CircuitBreakerException catch (e) {
      _circuitoAbierto = true;
      _mensajeError = e.message;
      // _presupuesto mantiene el último valor calculado (si existe).
    } catch (e) {
      _circuitoAbierto = _presupuestoRemoto.circuitoAbierto;
      _mensajeError = 'Error al obtener el presupuesto. Verifica tu red.';
    } finally {
      onCambio?.call();
    }
  }

  /// Reinicia el circuito manualmente y recalcula.
  Future<void> reintentar() async {
    _presupuestoRemoto.resetCircuito();
    await recalcular();
  }

  // ── Getters síncronos ────────────────────────────────────────────────────

  bool get estaExcedido =>
      _presupuesto != null && !_presupuesto!.dentroDelPresupuesto;

  bool get cercaDelLimite =>
      _presupuesto != null &&
      _presupuesto!.porcentajeUtilizado >= 80.0 &&
      !estaExcedido;

  double get costoTotal => _presupuesto?.costoTotal ?? 0.0;

  double get saldoRestante => _presupuesto?.saldoRestante ?? 0.0;

  double get porcentajeUtilizado => _presupuesto?.porcentajeUtilizado ?? 0.0;

  String get resumenTexto {
    if (_presupuesto == null) return 'Sin datos de presupuesto.';
    final p = _presupuesto!;
    return 'Total gastado : \$${p.costoTotal.toStringAsFixed(2)}\n'
        'Presupuesto   : \$${p.presupuestoMaximo.toStringAsFixed(2)}\n'
        'Disponible    : \$${p.saldoRestante.toStringAsFixed(2)}\n'
        'Utilizado     : ${p.porcentajeUtilizado.toStringAsFixed(1)} %\n'
        'Estado        : ${p.dentroDelPresupuesto ? "✅ Dentro del límite" : "⚠️ Excedido"}';
  }
}
