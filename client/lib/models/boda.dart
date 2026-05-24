// Archivo para el modelo de boda.



import 'invitado.dart';
import 'proveedor.dart';
import 'evento.dart';
import 'presupuesto.dart';





class Boda {

// Variable para id.
  final String id;

// Variable para nombre pareja1.
  final String nombrePareja1;

// Variable para nombre pareja2.
  final String nombrePareja2;

// Variable para fecha boda.
  final DateTime fechaBoda;

// Variable para lugar ceremonia.
  final String lugarCeremonia;

// Variable para lugar recepcion.
  final String lugarRecepcion;

// Variable para invitados.
  final List<Invitado> invitados;

// Variable para proveedores.
  final List<Proveedor> proveedores;

// Variable para eventos.
  final List<Evento> eventos;

// Variable para presupuesto.
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
