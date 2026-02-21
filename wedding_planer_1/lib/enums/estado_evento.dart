/// Ciclo de vida de un evento dentro de la boda (ceremonia, recepción, etc.).
enum EstadoEvento {
  planificado,
  enCurso,
  finalizado;

  /// Etiqueta legible para mostrar en la UI.
  String get etiqueta {
    switch (this) {
      case EstadoEvento.planificado:
        return 'Planificado';
      case EstadoEvento.enCurso:
        return 'En curso';
      case EstadoEvento.finalizado:
        return 'Finalizado';
    }
  }
}