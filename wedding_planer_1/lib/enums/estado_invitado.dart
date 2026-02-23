// Archivo para el enum de estado invitado.



enum EstadoInvitado {
  pendiente,
  confirmado,
  rechazado;

  
  String get etiqueta {
    switch (this) {
      case EstadoInvitado.pendiente:
        return 'Pendiente';
      case EstadoInvitado.confirmado:
        return 'Confirmado';
      case EstadoInvitado.rechazado:
        return 'Rechazado';
    }
  }
}
