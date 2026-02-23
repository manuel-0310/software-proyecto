// Archivo para el servicio de evento.



import '../models/evento.dart';
import '../enums/estado_evento.dart';
import '../repositories/interfaces/i_evento_repository.dart';





class EventoService {

// Variable para repositorio.
  final IEventoRepository _repository;

  const EventoService({required IEventoRepository repository})
      : _repository = repository;

  

  
  Evento crear({
    required String id,
    required String nombre,
    required String lugar,
    required DateTime fechaHora,
    required int duracionMinutos,
    String? descripcion,
  }) {
    final evento = Evento(
      id: id,
      nombre: nombre,
      lugar: lugar,
      fechaHora: fechaHora,
      duracionMinutos: duracionMinutos,
      descripcion: descripcion,
    );
    _repository.guardar(evento);
    return evento;
  }

  
  void eliminar(String id) => _repository.eliminar(id);

  
  List<Evento> obtenerTodos() => _repository.obtenerTodos();

  
  Evento? obtenerPorId(String id) => _repository.obtenerPorId(id);

  

  
  void actualizarEstado(String id, EstadoEvento nuevoEstado) {


// Variable para evento.
    final evento = _repository.obtenerPorId(id);
    if (evento == null) {
      throw StateError('Evento con id "$id" no encontrado.');
    }
    evento.estado = nuevoEstado;
    _repository.guardar(evento);
  }

  
List<Evento> obtenerOrdenados() {


// Variable para lista.
  final lista = List<Evento>.from(obtenerTodos()); 
  lista.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return lista;
}

  
  Evento? proximoEvento() {


// Variable para ahora.
    final ahora = DateTime.now();
    return obtenerOrdenados().cast<Evento?>().firstWhere(
          (e) => e!.fechaHora.isAfter(ahora),
          orElse: () => null,
        );
  }
}
