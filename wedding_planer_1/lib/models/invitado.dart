// Archivo para el modelo de invitado.



import '../enums/estado_invitado.dart';
import '../patterns/observer/invitado_observable.dart';
import '../patterns/observer/invitado_observer.dart';





class Invitado implements InvitadoObservable {

// Variable para id.
  final String id;

// Variable para nombre.
  final String nombre;

// Variable para apellido.
  final String apellido;

// Variable para correo.
  final String correo;

// Variable para telefono.
  final String? telefono;

// Variable para mesa asignada.
  final int? mesaAsignada;

// Variable para estado.
  EstadoInvitado estado;



// Variable para observers.
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

  

  
  void cambiarEstado(EstadoInvitado nuevoEstado) {
    estado = nuevoEstado;
    notificar();
  }

  String get nombreCompleto => '$nombre $apellido';

  @override
  String toString() =>
      'Invitado($nombreCompleto, estado: ${estado.etiqueta})';
}
