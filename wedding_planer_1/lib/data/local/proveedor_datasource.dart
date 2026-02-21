import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';

/// Fuente de datos local para proveedores (almacenamiento en memoria).
///
/// SRP  → única responsabilidad: leer y escribir proveedores en la capa de datos.
/// DIP  → los repositorios concretos dependen de esta clase, nunca los servicios.
class ProveedorDatasource {
  /// Mapa interno: id → Proveedor. Simula una tabla de base de datos.
  final Map<String, Proveedor> _almacen = {};

  // ── Operaciones CRUD ──────────────────────────────────────────────────────

  /// Guarda o actualiza un proveedor (upsert por id).
  void guardar(Proveedor proveedor) {
    _almacen[proveedor.id] = proveedor;
  }

  /// Elimina un proveedor por [id]. No lanza error si no existe.
  void eliminar(String id) => _almacen.remove(id);

  /// Retorna todos los proveedores como lista no modificable.
  List<Proveedor> obtenerTodos() =>
      List.unmodifiable(_almacen.values.toList());

  /// Retorna el proveedor con [id], o `null` si no existe.
  Proveedor? obtenerPorId(String id) => _almacen[id];

  /// Retorna proveedores filtrados por [tipo].
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo) =>
      _almacen.values.where((p) => p.tipo == tipo).toList();

  /// Número de proveedores almacenados.
  int get cantidad => _almacen.length;

  /// Elimina todos los proveedores (útil para tests y reinicio de la app).
  void limpiar() => _almacen.clear();
}