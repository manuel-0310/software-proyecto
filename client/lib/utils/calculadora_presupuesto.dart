// Archivo para la utilidad de calculadora presupuesto.



import '../models/invitado.dart';
import '../models/proveedor.dart';
import '../enums/estado_invitado.dart';










class CalculadoraPresupuesto {
  
  CalculadoraPresupuesto._();

  

  
  static int contarConfirmados(List<Invitado> invitados) =>
      invitados.where((i) => i.estado == EstadoInvitado.confirmado).length;

  
  static double costoInvitados({
    required List<Invitado> invitados,
    required double costoPorPersona,
  }) =>
      contarConfirmados(invitados) * costoPorPersona;

  

  
  static double costoProveedores(List<Proveedor> proveedores) =>
      proveedores.fold(0.0, (suma, p) => suma + p.calcularCostoFinal());

  
  static Map<String, double> desglosePorProveedor(
          List<Proveedor> proveedores) =>
      {for (final p in proveedores) p.nombre: p.calcularCostoFinal()};

  

  
  static double costoTotal({
    required List<Invitado> invitados,
    required List<Proveedor> proveedores,
    required double costoPorPersona,
  }) =>
      costoInvitados(invitados: invitados, costoPorPersona: costoPorPersona) +
      costoProveedores(proveedores);

  
  static double saldoRestante({
    required double presupuestoMaximo,
    required double costoActual,
  }) =>
      presupuestoMaximo - costoActual;

  
  static double porcentajeUtilizado({
    required double presupuestoMaximo,
    required double costoActual,
  }) {
    if (presupuestoMaximo <= 0) return 0.0;
    return (costoActual / presupuestoMaximo) * 100;
  }

  
  static bool estaExcedido({
    required double presupuestoMaximo,
    required double costoActual,
  }) =>

// Variable para presupuesto maximo.
      costoActual > presupuestoMaximo;

  
  static bool cercaDelLimite({
    required double presupuestoMaximo,
    required double costoActual,
    double umbral = 80.0,
  }) =>
      porcentajeUtilizado(
            presupuestoMaximo: presupuestoMaximo,
            costoActual: costoActual,
          ) >=
      umbral;
}
