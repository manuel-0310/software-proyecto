// Archivo para el servicio de notificacion.









abstract class NotificacionService {
  
  void enviar({
    required String destinatario,
    required String asunto,
    required String mensaje,
  });
}




class ConsoleNotificacionService implements NotificacionService {
  @override
  void enviar({
    required String destinatario,
    required String asunto,
    required String mensaje,
  }) {
    
    print(
      '\n📨 NOTIFICACIÓN'
      '\n  Para   : $destinatario'
      '\n  Asunto : $asunto'
      '\n  Mensaje: $mensaje\n',
    );
  }
}
