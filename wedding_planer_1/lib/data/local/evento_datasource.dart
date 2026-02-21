import '../models/evento.dart';
import '../enums/estado_evento.dart';

/// Fuente de datos local para eventos (almacenamiento en memoria).
///
/// SRP  → única responsabilidad: leer y escribir eventos en la capa de datos.
/// DIP  → los repositorios concretos dependen de esta clase, nunca los servicios.
class EventoDatasource {
  /// Mapa interno: id → Evento. Simula una tabla de base de datos.
  final Map<String, Evento> _almacen = {};

  // ── Operaciones CRUD ──────────────────────────────────────────────────────

  /// Guarda o actualiza un evento (upsert por id).
  void guardar(Evento evento) {
    _almacen[evento.id] = evento;
  }

  /// Elimina un evento por [id]. No lanza error si no existe.
  void eliminar(String id) => _almacen.remove(id);

  /// Retorna todos los eventos como lista no modificable.
  List<Evento> obtenerTodos() =>
      List.unmodifiable(_almacen.values.toList());

  /// Retorna el evento con [id], o `null` si no existe.
  Evento? obtenerPorId(String id) => _almacen[id];

  /// Retorna eventos filtrados por [estado].
  List<Evento> obtenerPorEstado(EstadoEvento estado) =>
      _almacen.values.where((e) => e.estado == estado).toList();

  /// Retorna eventos ordenados cronológicamente (más próximo primero).
  List<Evento> obtenerOrdenados() {
    final lista = _almacen.values.toList();
    lista.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return lista;
  }

  /// Número de eventos almacenados.
  int get cantidad => _almacen.length;

  /// Elimina todos los eventos (útil para tests y reinicio de la app).
  void limpiar() => _almacen.clear();
}