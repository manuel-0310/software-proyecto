/// Contrato del observador en el patrón Observer.
///
/// DIP  → los observadores concretos implementan esta interfaz.
/// SRP  → cada observador concreto tiene una única reacción al evento.
/// OCP  → se añaden nuevos observadores creando clases, no modificando código.
abstract class InvitadoObserver {
  /// Se invoca automáticamente cuando el estado de [invitado] cambia.
  /// Recibe la instancia completa para acceder a cualquier dato necesario.
  void actualizar(covariant dynamic invitado);
}