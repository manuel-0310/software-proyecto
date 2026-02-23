// Archivo para el patron observer de notificacion.



import 'invitado_observer.dart';
import '../../models/invitado.dart';
import '../../enums/estado_invitado.dart';
import '../../services/notificacion_service.dart';







class NotificacionObserver implements InvitadoObserver {

// Variable para notificacion servicio.
  final NotificacionService _notificacionService;

  const NotificacionObserver(this._notificacionService);

  @override
  void actualizar(Invitado invitado) {


// Variable para mensaje.
    final mensaje = _construirMensaje(invitado);
    _notificacionService.enviar(
      destinatario: invitado.correo,
      asunto: 'Actualización de tu invitación',
      mensaje: mensaje,
    );
  }

  String _construirMensaje(Invitado invitado) {
    switch (invitado.estado) {
      case EstadoInvitado.confirmado:
        return '¡Hola ${invitado.nombre}! Tu asistencia ha sido confirmada. '
            'Te esperamos con mucho cariño.';
      case EstadoInvitado.rechazado:
        return 'Hola ${invitado.nombre}, lamentamos que no puedas acompañarnos. '
            'Gracias por avisarnos.';
      case EstadoInvitado.pendiente:
        return 'Hola ${invitado.nombre}, tu invitación aún está pendiente de confirmación. '
            '¡Esperamos verte pronto!';
    }
  }
}
