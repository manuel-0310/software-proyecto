import 'invitado_observer.dart';

/// Contrato del sujeto en el patrón Observer.
///
/// DIP → [Invitado] depende de esta abstracción, no de observadores concretos.
/// OCP → se pueden agregar nuevos observadores sin modificar el sujeto.
abstract class InvitadoObservable {
  /// Registra un [observer] para recibir notificaciones de cambio de estado.
  void suscribir(InvitadoObserver observer);

  /// Elimina un [observer] previamente registrado.
  void eliminar(InvitadoObserver observer);

  /// Notifica a todos los observadores registrados sobre un cambio de estado.
  void notificar();
}