import '../enums/estado_evento.dart';

/// Representa un evento dentro de la boda (ej: ceremonia, recepción, cena).
///
/// SRP → solo almacena información y estado del evento. Sin lógica de negocio.
class Evento {
  final String id;
  final String nombre;
  final String lugar;
  final DateTime fechaHora;
  final int duracionMinutos;
  EstadoEvento estado;
  final String? descripcion;

  Evento({
    required this.id,
    required this.nombre,
    required this.lugar,
    required this.fechaHora,
    required this.duracionMinutos,
    this.estado = EstadoEvento.planificado,
    this.descripcion,
  });

  DateTime get fechaFin =>
      fechaHora.add(Duration(minutes: duracionMinutos));

  bool get estaActivo => estado == EstadoEvento.enCurso;

  @override
  String toString() =>
      'Evento($nombre, ${estado.etiqueta}, $lugar)';
}