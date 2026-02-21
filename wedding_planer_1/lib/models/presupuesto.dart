import 'invitado.dart';
import 'proveedor.dart';

/// Modelo que representa el presupuesto total de la boda.
///
/// SRP  → única responsabilidad: agregar costos y exponer totales.
/// Observer → actúa como receptor: se recalcula cuando un invitado cambia estado.
class Presupuesto {
  final double presupuestoMaximo;
  final double costoPorInvitadoConfirmado;
  final List<Proveedor> proveedores;
  final List<Invitado> invitados;

  const Presupuesto({
    required this.presupuestoMaximo,
    required this.costoPorInvitadoConfirmado,
    required this.proveedores,
    required this.invitados,
  });

  // ── Cálculos ──────────────────────────────────────────────────────────────

  int get totalConfirmados =>
      invitados.where((i) => i.estado.name == 'confirmado').length;

  double get costoInvitados =>
      totalConfirmados * costoPorInvitadoConfirmado;

  double get costoProveedores =>
      proveedores.fold(0.0, (sum, p) => sum + p.calcularCostoFinal());

  double get costoTotal => costoInvitados + costoProveedores;

  double get saldoRestante => presupuestoMaximo - costoTotal;

  bool get dentroDelPresupuesto => costoTotal <= presupuestoMaximo;

  double get porcentajeUtilizado =>
      presupuestoMaximo > 0 ? (costoTotal / presupuestoMaximo) * 100 : 0;

  @override
  String toString() =>
      'Presupuesto(total: \$${costoTotal.toStringAsFixed(2)} / max: \$${presupuestoMaximo.toStringAsFixed(2)})';
}