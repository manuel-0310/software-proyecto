import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import '../../data/local/proveedor_datasource.dart';
import '../interfaces/i_proveedor_repository.dart';

/// Implementación concreta del repositorio de proveedores.
/// Usa [ProveedorDatasource] como fuente de datos local (en memoria).
///
/// DIP  → implementa [IProveedorRepository]; el servicio opera sobre la
///        interfaz y nunca conoce esta clase concreta.
/// SRP  → única responsabilidad: traducir llamadas del servicio en
///        operaciones sobre el datasource.
class ProveedorRepositoryImpl implements IProveedorRepository {
  final ProveedorDatasource _datasource;

  const ProveedorRepositoryImpl({required ProveedorDatasource datasource})
      : _datasource = datasource;

  @override
  void guardar(Proveedor proveedor) => _datasource.guardar(proveedor);

  @override
  void eliminar(String id) => _datasource.eliminar(id);

  @override
  List<Proveedor> obtenerTodos() => _datasource.obtenerTodos();

  @override
  Proveedor? obtenerPorId(String id) => _datasource.obtenerPorId(id);

  @override
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo) =>
      _datasource.obtenerPorTipo(tipo);
}