import '../models/invitado.dart';
import '../models/proveedor.dart';
import '../enums/estado_invitado.dart';

/// Funciones puras para el cálculo de costos del presupuesto de la boda.
///
/// SRP  → única responsabilidad: aritmética de presupuesto. Sin estado,
///        sin dependencias de UI ni de servicios.
/// DIP  → opera sobre abstracciones ([Invitado], [Proveedor]) no sobre
///        implementaciones concretas de proveedores o repositorios.
///
/// Al ser funciones puras (mismo input → mismo output, sin efectos secundarios)
/// son trivialmente testeables con unit tests.
class CalculadoraPresupuesto {
  // Constructor privado: esta clase solo tiene métodos estáticos.
  CalculadoraPresupuesto._();

  // ── Invitados ─────────────────────────────────────────────────────────────

  /// Cuenta los invitados con [EstadoInvitado.confirmado].
  static int contarConfirmados(List<Invitado> invitados) =>
      invitados.where((i) => i.estado == EstadoInvitado.confirmado).length;

  /// Calcula el costo total de invitados confirmados.
  static double costoInvitados({
    required List<Invitado> invitados,
    required double costoPorPersona,
  }) =>
      contarConfirmados(invitados) * costoPorPersona;

  // ── Proveedores ───────────────────────────────────────────────────────────

  /// Suma el costo final de todos los proveedores contratados.
  static double costoProveedores(List<Proveedor> proveedores) =>
      proveedores.fold(0.0, (suma, p) => suma + p.calcularCostoFinal());

  /// Retorna el desglose de costos por proveedor como mapa nombre → costo.
  static Map<String, double> desglosePorProveedor(
          List<Proveedor> proveedores) =>
      {for (final p in proveedores) p.nombre: p.calcularCostoFinal()};

  // ── Totales ───────────────────────────────────────────────────────────────

  /// Calcula el costo total de la boda (invitados + proveedores).
  static double costoTotal({
    required List<Invitado> invitados,
    required List<Proveedor> proveedores,
    required double costoPorPersona,
  }) =>
      costoInvitados(invitados: invitados, costoPorPersona: costoPorPersona) +
      costoProveedores(proveedores);

  /// Calcula el saldo restante dado un presupuesto máximo.
  static double saldoRestante({
    required double presupuestoMaximo,
    required double costoActual,
  }) =>
      presupuestoMaximo - costoActual;

  /// Porcentaje del presupuesto máximo ya utilizado (0–100+).
  static double porcentajeUtilizado({
    required double presupuestoMaximo,
    required double costoActual,
  }) {
    if (presupuestoMaximo <= 0) return 0.0;
    return (costoActual / presupuestoMaximo) * 100;
  }

  /// Retorna `true` si el costo supera el presupuesto máximo.
  static bool estaExcedido({
    required double presupuestoMaximo,
    required double costoActual,
  }) =>
      costoActual > presupuestoMaximo;

  /// Retorna `true` si se ha superado el [umbral] % del presupuesto.
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