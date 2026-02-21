import '../models/proveedor.dart';
import '../enums/tipo_proveedor.dart';
import '../repositories/interfaces/i_proveedor_repository.dart';

/// Lógica de negocio exclusiva para la gestión de proveedores.
///
/// SRP  → única responsabilidad: operaciones de negocio sobre proveedores.
/// DIP  → depende de [IProveedorRepository] (interfaz), no de la implementación.
class ProveedorService {
  final IProveedorRepository _repository;

  const ProveedorService({required IProveedorRepository repository})
      : _repository = repository;

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Persiste un proveedor ya construido (creado previamente por la Factory).
  void contratar(Proveedor proveedor) => _repository.guardar(proveedor);

  /// Elimina el contrato con el proveedor identificado por [id].
  void cancelar(String id) => _repository.eliminar(id);

  /// Retorna todos los proveedores contratados.
  List<Proveedor> obtenerTodos() => _repository.obtenerTodos();

  /// Retorna un proveedor por [id], o `null` si no existe.
  Proveedor? obtenerPorId(String id) => _repository.obtenerPorId(id);

  // ── Consultas ─────────────────────────────────────────────────────────────

  /// Filtra proveedores por [tipo] (DJ, Catering, Fotografía).
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo) =>
      obtenerTodos().where((p) => p.tipo == tipo).toList();

  /// Retorna el proveedor más económico de un [tipo] específico.
  Proveedor? masEconomico(TipoProveedor tipo) {
    final lista = obtenerPorTipo(tipo);
    if (lista.isEmpty) return null;
    return lista.reduce(
      (a, b) => a.calcularCostoFinal() <= b.calcularCostoFinal() ? a : b,
    );
  }

  /// Suma el costo final de todos los proveedores contratados.
  double costoTotalProveedores() => obtenerTodos().fold(
        0.0,
        (sum, p) => sum + p.calcularCostoFinal(),
      );
}