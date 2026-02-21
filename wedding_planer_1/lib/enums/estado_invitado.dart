/// Representa los posibles estados de asistencia de un invitado a la boda.
enum EstadoInvitado {
  pendiente,
  confirmado,
  rechazado;

  /// Etiqueta legible para mostrar en la UI.
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