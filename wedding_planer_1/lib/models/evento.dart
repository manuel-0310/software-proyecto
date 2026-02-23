// Archivo para el modelo de evento.



import '../enums/estado_evento.dart';




class Evento {

// Variable para id.
  final String id;

// Variable para nombre.
  final String nombre;

// Variable para lugar.
  final String lugar;

// Variable para fecha hora.
  final DateTime fechaHora;

// Variable para duracion minutos.
  final int duracionMinutos;

// Variable para estado.
  EstadoEvento estado;

// Variable para descripcion.
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
