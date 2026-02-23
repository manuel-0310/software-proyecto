// Archivo para el modelo de presupuesto.



import 'invitado.dart';
import 'proveedor.dart';





class Presupuesto {

// Variable para presupuesto maximo.
  final double presupuestoMaximo;

// Variable para costo por invitado confirmado.
  final double costoPorInvitadoConfirmado;

// Variable para proveedores.
  final List<Proveedor> proveedores;

// Variable para invitados.
  final List<Invitado> invitados;

  const Presupuesto({
    required this.presupuestoMaximo,
    required this.costoPorInvitadoConfirmado,
    required this.proveedores,
    required this.invitados,
  });

  

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
