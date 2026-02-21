import '../models/invitado.dart';

/// Fuente de datos local para invitados (almacenamiento en memoria).
///
/// SRP  → única responsabilidad: leer y escribir invitados en la capa de datos.
/// DIP  → los repositorios concretos dependen de esta clase; los servicios
///        nunca la tocan directamente.
///
/// En producción se sustituiría por una implementación con SQLite, Hive, etc.
/// sin cambiar nada más arriba en la arquitectura.
class InvitadoDatasource {
  /// Mapa interno: id → Invitado. Simula una tabla de base de datos.
  final Map<String, Invitado> _almacen = {};

  // ── Operaciones CRUD ──────────────────────────────────────────────────────

  /// Guarda o actualiza un invitado (upsert por id).
  void guardar(Invitado invitado) {
    _almacen[invitado.id] = invitado;
  }

  /// Elimina un invitado por [id]. No lanza error si no existe.
  void eliminar(String id) => _almacen.remove(id);

  /// Retorna todos los invitados como lista no modificable.
  List<Invitado> obtenerTodos() => List.unmodifiable(_almacen.values.toList());

  /// Retorna el invitado con [id], o `null` si no existe.
  Invitado? obtenerPorId(String id) => _almacen[id];

  /// Número de invitados almacenados.
  int get cantidad => _almacen.length;

  /// Elimina todos los invitados (útil para tests y reinicio de la app).
  void limpiar() => _almacen.clear();
}