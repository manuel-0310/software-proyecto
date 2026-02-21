/// Contrato para el envío de notificaciones del sistema.
///
/// DIP  → los observadores y controllers dependen de esta abstracción,
///        no de una implementación concreta (email, push, SMS, etc.).
/// OCP  → se puede cambiar el canal de notificación creando una nueva
///        implementación sin modificar los observadores que la usan.
/// SRP  → única responsabilidad: definir cómo se envía una notificación.
abstract class NotificacionService {
  /// Envía una notificación al [destinatario] con el [asunto] y [mensaje] dados.
  void enviar({
    required String destinatario,
    required String asunto,
    required String mensaje,
  });
}

/// Implementación de consola para desarrollo y pruebas universitarias.
/// En producción se reemplaza por una implementación real (Firebase, email, etc.)
/// sin modificar nada más gracias a DIP.
class ConsoleNotificacionService implements NotificacionService {
  @override
  void enviar({
    required String destinatario,
    required String asunto,
    required String mensaje,
  }) {
    // ignore: avoid_print
    print(
      '\n📨 NOTIFICACIÓN'
      '\n  Para   : $destinatario'
      '\n  Asunto : $asunto'
      '\n  Mensaje: $mensaje\n',
    );
  }
}