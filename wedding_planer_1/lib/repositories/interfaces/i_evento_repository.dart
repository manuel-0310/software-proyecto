import '../../models/evento.dart';
import '../../enums/estado_evento.dart';

/// Contrato abstracto para la persistencia de eventos de boda.
///
/// DIP  → [EventoService] depende de esta interfaz, nunca de la implementación.
/// OCP  → se puede migrar a cualquier motor de datos sin alterar la capa de
///        servicios ni los controllers.
abstract class IEventoRepository {
  /// Guarda o actualiza un [evento] (upsert por id).
  void guardar(Evento evento);

  /// Elimina el evento con [id]. No lanza error si no existe.
  void eliminar(String id);

  /// Retorna todos los eventos registrados.
  List<Evento> obtenerTodos();

  /// Retorna el evento con [id], o `null` si no existe.
  Evento? obtenerPorId(String id);

  /// Retorna eventos filtrados por [estado].
  List<Evento> obtenerPorEstado(EstadoEvento estado);

  /// Retorna eventos ordenados cronológicamente (más próximo primero).
  List<Evento> obtenerOrdenados();
}