// Archivo para el servicio de invitado.



import '../models/invitado.dart';
import '../enums/estado_invitado.dart';
import '../repositories/interfaces/i_invitado_repository.dart';
import '../patterns/observer/invitado_observer.dart';





class InvitadoService {

// Variable para repositorio.
  final IInvitadoRepository _repository;

  

// Variable para observadores globales.
  final List<InvitadoObserver> _observadoresGlobales;

  InvitadoService({
    required IInvitadoRepository repository,
    List<InvitadoObserver> observadoresGlobales = const [],
  })  : _repository = repository,
        _observadoresGlobales = observadoresGlobales;

  

  
  Invitado agregar({
    required String id,
    required String nombre,
    required String apellido,
    required String correo,
    String? telefono,
    int? mesaAsignada,
  }) {
    final invitado = Invitado(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      mesaAsignada: mesaAsignada,
    );

    for (final obs in _observadoresGlobales) {
      invitado.suscribir(obs);
    }

    _repository.guardar(invitado);
    return invitado;
  }

  
  void eliminar(String id) => _repository.eliminar(id);

  
  List<Invitado> obtenerTodos() => _repository.obtenerTodos();

  
  Invitado? obtenerPorId(String id) => _repository.obtenerPorId(id);

  

  
  void cambiarEstado(String id, EstadoInvitado nuevoEstado) {


// Variable para invitado.
    final invitado = _repository.obtenerPorId(id);
    if (invitado == null) {
      throw StateError('Invitado con id "$id" no encontrado.');
    }
    invitado.cambiarEstado(nuevoEstado); 
    _repository.guardar(invitado);
  }

  
  List<Invitado> obtenerConfirmados() => obtenerTodos()
      .where((i) => i.estado == EstadoInvitado.confirmado)
      .toList();

  
  Map<EstadoInvitado, int> resumenPorEstado() {


// Variable para todos.
    final todos = obtenerTodos();
    return {
      for (final estado in EstadoInvitado.values)
        estado: todos.where((i) => i.estado == estado).length,
    };
  }
}
