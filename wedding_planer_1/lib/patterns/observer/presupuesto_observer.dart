import 'invitado_observer.dart';
import '../../models/invitado.dart';
import '../../models/presupuesto.dart';
import '../../enums/estado_invitado.dart';

/// Observador concreto que recalcula y registra el impacto presupuestario
/// cada vez que el estado de un invitado cambia.
///
/// SRP  → única responsabilidad: actualizar y registrar el presupuesto.
/// OCP  → extiende el comportamiento del sistema sin modificar [Invitado]
///        ni [Presupuesto].
class PresupuestoObserver implements InvitadoObserver {
  final Presupuesto presupuesto;

  /// Callback opcional para notificar a la UI del nuevo costo total.
  final void Function(double costoTotal)? onPresupuestoActualizado;

  const PresupuestoObserver({
    required this.presupuesto,
    this.onPresupuestoActualizado,
  });

  @override
  void actualizar(Invitado invitado) {
    // Presupuesto recalcula automáticamente vía getters (no necesita mutación).
    final nuevoTotal = presupuesto.costoTotal;

    _registrarCambio(invitado, nuevoTotal);
    onPresupuestoActualizado?.call(nuevoTotal);
  }

  void _registrarCambio(Invitado invitado, double nuevoTotal) {
    final accion = invitado.estado == EstadoInvitado.confirmado
        ? 'sumó al'
        : 'se eliminó del';
    // En producción esto iría a un logger; aquí lo dejamos como print para debug.
    // ignore: avoid_print
    print(
      '[Presupuesto] ${invitado.nombreCompleto} $accion presupuesto. '
      'Total actual: \$${nuevoTotal.toStringAsFixed(2)} | '
      'Disponible: \$${presupuesto.saldoRestante.toStringAsFixed(2)}',
    );
  }
}