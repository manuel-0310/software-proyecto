import '../enums/estado_invitado.dart';
import '../patterns/observer/invitado_observable.dart';
import '../patterns/observer/invitado_observer.dart';

/// Modelo que representa a un invitado a la boda.
///
/// SRP  → solo contiene datos y estado del invitado.
/// Observer → implementa [InvitadoObservable] para notificar cambios de estado.
class Invitado implements InvitadoObservable {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final int? mesaAsignada;
  EstadoInvitado estado;

  final List<InvitadoObserver> _observers = [];

  Invitado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    this.mesaAsignada,
    this.estado = EstadoInvitado.pendiente,
  });

  // ── Observer ──────────────────────────────────────────────────────────────

  @override
  void suscribir(InvitadoObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  @override
  void eliminar(InvitadoObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notificar() {
    for (final observer in _observers) {
      observer.actualizar(this);
    }
  }

  // ── Lógica de dominio ─────────────────────────────────────────────────────

  /// Cambia el estado del invitado y notifica a todos los observadores.
  void cambiarEstado(EstadoInvitado nuevoEstado) {
    estado = nuevoEstado;
    notificar();
  }

  String get nombreCompleto => '$nombre $apellido';

  @override
  String toString() =>
      'Invitado($nombreCompleto, estado: ${estado.etiqueta})';
}