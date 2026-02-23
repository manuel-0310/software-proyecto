// Archivo para el servicio de presupuesto.



import '../models/presupuesto.dart';
import '../models/invitado.dart';
import '../models/proveedor.dart';





class PresupuestoService {

// Variable para presupuesto maximo.
  final double presupuestoMaximo;

// Variable para costo por invitado confirmado.
  final double costoPorInvitadoConfirmado;

  const PresupuestoService({
    required this.presupuestoMaximo,
    required this.costoPorInvitadoConfirmado,
  });

  

  
  
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

  

  
  bool estaExcedido(Presupuesto presupuesto) =>
      !presupuesto.dentroDelPresupuesto;

  
  
  bool cercaDelLimite(Presupuesto presupuesto,
          {double umbralPorcentaje = 80.0}) =>
      presupuesto.porcentajeUtilizado >= umbralPorcentaje;

  
  String resumenTexto(Presupuesto presupuesto) {
    return 'Total gastado : \$${presupuesto.costoTotal.toStringAsFixed(2)}\n'
        'Presupuesto   : \$${presupuesto.presupuestoMaximo.toStringAsFixed(2)}\n'
        'Disponible    : \$${presupuesto.saldoRestante.toStringAsFixed(2)}\n'
        'Utilizado     : ${presupuesto.porcentajeUtilizado.toStringAsFixed(1)} %\n'
        'Estado        : ${presupuesto.dentroDelPresupuesto ? "✅ Dentro del límite" : "⚠️ Excedido"}';
  }
}
