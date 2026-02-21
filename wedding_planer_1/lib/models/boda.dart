import 'invitado.dart';
import 'proveedor.dart';
import 'evento.dart';
import 'presupuesto.dart';

/// Entidad raíz del sistema. Agrupa todos los componentes de una boda.
///
/// SRP → solo representa los datos de la boda y expone accesores básicos.
///       La lógica de negocio vive en los servicios correspondientes.
class Boda {
  final String id;
  final String nombrePareja1;
  final String nombrePareja2;
  final DateTime fechaBoda;
  final String lugarCeremonia;
  final String lugarRecepcion;
  final List<Invitado> invitados;
  final List<Proveedor> proveedores;
  final List<Evento> eventos;
  final Presupuesto presupuesto;

  const Boda({
    required this.id,
    required this.nombrePareja1,
    required this.nombrePareja2,
    required this.fechaBoda,
    required this.lugarCeremonia,
    required this.lugarRecepcion,
    required this.invitados,
    required this.proveedores,
    required this.eventos,
    required this.presupuesto,
  });

  // ── Accesores de conveniencia ─────────────────────────────────────────────

  String get titulo => '$nombrePareja1 & $nombrePareja2';

  int get totalInvitados => invitados.length;

  int get invitadosConfirmados =>
      invitados.where((i) => i.estado.name == 'confirmado').length;

  int get diasRestantes =>
      fechaBoda.difference(DateTime.now()).inDays;

  bool get yaOcurrio => fechaBoda.isBefore(DateTime.now());

  @override
  String toString() =>
      'Boda($titulo, ${fechaBoda.toIso8601String().substring(0, 10)})';
}