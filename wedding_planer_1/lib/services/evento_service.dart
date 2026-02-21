import '../models/evento.dart';
import '../enums/estado_evento.dart';
import '../repositories/interfaces/i_evento_repository.dart';

/// Lógica de negocio exclusiva para la gestión de eventos de la boda.
///
/// SRP  → única responsabilidad: operaciones de negocio sobre eventos.
/// DIP  → depende de [IEventoRepository] (interfaz), no de la implementación.
class EventoService {
  final IEventoRepository _repository;

  const EventoService({required IEventoRepository repository})
      : _repository = repository;

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Crea y persiste un nuevo evento de boda.
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

  /// Elimina un evento por [id].
  void eliminar(String id) => _repository.eliminar(id);

  /// Retorna todos los eventos registrados.
  List<Evento> obtenerTodos() => _repository.obtenerTodos();

  /// Retorna un evento por [id], o `null` si no existe.
  Evento? obtenerPorId(String id) => _repository.obtenerPorId(id);

  // ── Lógica de negocio ─────────────────────────────────────────────────────

  /// Actualiza el estado de un evento (planificado → enCurso → finalizado).
  void actualizarEstado(String id, EstadoEvento nuevoEstado) {
    final evento = _repository.obtenerPorId(id);
    if (evento == null) {
      throw StateError('Evento con id "$id" no encontrado.');
    }
    evento.estado = nuevoEstado;
    _repository.guardar(evento);
  }

  /// Retorna eventos ordenados cronológicamente.
List<Evento> obtenerOrdenados() {
  final lista = List<Evento>.from(obtenerTodos()); // ✅ copia mutable
  lista.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return lista;
}

  /// Retorna el próximo evento que aún no ha finalizado.
  Evento? proximoEvento() {
    final ahora = DateTime.now();
    return obtenerOrdenados().cast<Evento?>().firstWhere(
          (e) => e!.fechaHora.isAfter(ahora),
          orElse: () => null,
        );
  }
}