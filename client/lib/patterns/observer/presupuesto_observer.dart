// Archivo para el patron observer de presupuesto.



import 'invitado_observer.dart';
import '../../models/invitado.dart';
import '../../models/presupuesto.dart';
import '../../enums/estado_invitado.dart';







class PresupuestoObserver implements InvitadoObserver {

// Variable para presupuesto.
  final Presupuesto presupuesto;

  
// Variable para on presupuesto actualizado.
  final void Function(double costoTotal)? onPresupuestoActualizado;

  const PresupuestoObserver({
    required this.presupuesto,
    this.onPresupuestoActualizado,
  });

  @override
  void actualizar(Invitado invitado) {
    


// Variable para nuevo total.
    final nuevoTotal = presupuesto.costoTotal;

    _registrarCambio(invitado, nuevoTotal);
    onPresupuestoActualizado?.call(nuevoTotal);
  }

  void _registrarCambio(Invitado invitado, double nuevoTotal) {
    final accion = invitado.estado == EstadoInvitado.confirmado
        ? 'sumó al'
        : 'se eliminó del';
    
    
    print(
      '[Presupuesto] ${invitado.nombreCompleto} $accion presupuesto. '
      'Total actual: \$${nuevoTotal.toStringAsFixed(2)} | '
      'Disponible: \$${presupuesto.saldoRestante.toStringAsFixed(2)}',
    );
  }
}
