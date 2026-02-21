import '../models/presupuesto.dart';
import '../models/invitado.dart';
import '../models/proveedor.dart';

/// Orquesta la construcción y consulta del presupuesto de la boda.
///
/// SRP  → única responsabilidad: construir el modelo [Presupuesto] con los
///        datos actuales y exponer métricas de negocio.
class PresupuestoService {
  final double presupuestoMaximo;
  final double costoPorInvitadoConfirmado;

  const PresupuestoService({
    required this.presupuestoMaximo,
    required this.costoPorInvitadoConfirmado,
  });

  // ── Factory de modelo ─────────────────────────────────────────────────────

  /// Construye un objeto [Presupuesto] con los [invitados] y [proveedores]
  /// actuales. Como usa getters, siempre refleja el estado en tiempo real.
  Presupuesto calcular({
    required List<Invitado> invitados,
    required List<Proveedor> proveedores,
  }) {
    return Presupuesto(
      presupuestoMaximo: presupuestoMaximo,
      costoPorInvitadoConfirmado: costoPorInvitadoConfirmado,
      invitados: invitados,
      proveedores: proveedores,
    );
  }

  // ── Consultas de negocio ──────────────────────────────────────────────────

  /// Retorna `true` si el costo total supera el presupuesto máximo.
  bool estaExcedido(Presupuesto presupuesto) =>
      !presupuesto.dentroDelPresupuesto;

  /// Alerta si el presupuesto supera el [umbralPorcentaje] del máximo.
  /// Por defecto avisa al llegar al 80 %.
  bool cercaDelLimite(Presupuesto presupuesto,
          {double umbralPorcentaje = 80.0}) =>
      presupuesto.porcentajeUtilizado >= umbralPorcentaje;

  /// Texto de resumen listo para mostrar en la UI o en reportes.
  String resumenTexto(Presupuesto presupuesto) {
    return 'Total gastado : \$${presupuesto.costoTotal.toStringAsFixed(2)}\n'
        'Presupuesto   : \$${presupuesto.presupuestoMaximo.toStringAsFixed(2)}\n'
        'Disponible    : \$${presupuesto.saldoRestante.toStringAsFixed(2)}\n'
        'Utilizado     : ${presupuesto.porcentajeUtilizado.toStringAsFixed(1)} %\n'
        'Estado        : ${presupuesto.dentroDelPresupuesto ? "✅ Dentro del límite" : "⚠️ Excedido"}';
  }
}