import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';

/// Contrato abstracto para la persistencia de proveedores.
///
/// DIP  → [ProveedorService] depende de esta interfaz, no de la implementación.
/// OCP  → se puede cambiar el motor de persistencia creando una nueva clase
///        que implemente este contrato, sin tocar nada en services ni controllers.
abstract class IProveedorRepository {
  /// Guarda o actualiza un [proveedor] (upsert por id).
  void guardar(Proveedor proveedor);

  /// Elimina el proveedor con [id]. No lanza error si no existe.
  void eliminar(String id);

  /// Retorna todos los proveedores contratados.
  List<Proveedor> obtenerTodos();

  /// Retorna el proveedor con [id], o `null` si no existe.
  Proveedor? obtenerPorId(String id);

  /// Retorna proveedores filtrados por [tipo].
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo);
}