// Archivo para el enum de estado evento.



enum EstadoEvento {
  planificado,
  enCurso,
  finalizado;

  
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
