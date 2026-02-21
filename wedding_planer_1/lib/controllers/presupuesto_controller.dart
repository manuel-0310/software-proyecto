import '../models/presupuesto.dart';
import '../services/presupuesto_service.dart';
import '../services/invitado_service.dart';
import '../services/proveedor_service.dart';

/// Expone el presupuesto calculado en tiempo real a la UI.
/// Orquesta [PresupuestoService], [InvitadoService] y [ProveedorService]
/// para construir el snapshot más reciente del presupuesto.
///
/// SRP  → única responsabilidad: mantener actualizado el estado del presupuesto
///        que consume la pantalla de presupuesto.
class PresupuestoController {
  final PresupuestoService _presupuestoService;
  final InvitadoService _invitadoService;
  final ProveedorService _proveedorService;

  Presupuesto? _presupuesto;
  Presupuesto? get presupuesto => _presupuesto;

  final void Function()? onCambio;

  PresupuestoController({
    required PresupuestoService presupuestoService,
    required InvitadoService invitadoService,
    required ProveedorService proveedorService,
    this.onCambio,
  })  : _presupuestoService = presupuestoService,
        _invitadoService = invitadoService,
        _proveedorService = proveedorService {
    recalcular();
  }

  // ── Cálculo ───────────────────────────────────────────────────────────────

  /// Reconstruye el presupuesto con los datos más recientes.
  /// Debe llamarse cada vez que cambien invitados o proveedores.
  void recalcular() {
    _presupuesto = _presupuestoService.calcular(
      invitados: _invitadoService.obtenerTodos(),
      proveedores: _proveedorService.obtenerTodos(),
    );
    onCambio?.call();
  }

  // ── Consultas para la UI ──────────────────────────────────────────────────

  bool get estaExcedido =>
      _presupuesto != null &&
      _presupuestoService.estaExcedido(_presupuesto!);

  bool get cercaDelLimite =>
      _presupuesto != null &&
      _presupuestoService.cercaDelLimite(_presupuesto!);

  double get costoTotal => _presupuesto?.costoTotal ?? 0.0;

  double get saldoRestante => _presupuesto?.saldoRestante ?? 0.0;

  double get porcentajeUtilizado =>
      _presupuesto?.porcentajeUtilizado ?? 0.0;

  String get resumenTexto => _presupuesto != null
      ? _presupuestoService.resumenTexto(_presupuesto!)
      : 'Sin datos de presupuesto.';
}