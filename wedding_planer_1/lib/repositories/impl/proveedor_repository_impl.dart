// Archivo para la implementacion del repositorio de proveedor.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import '../../data/local/proveedor_datasource.dart';
import '../interfaces/i_proveedor_repository.dart';








class ProveedorRepositoryImpl implements IProveedorRepository {

// Variable para datasource.
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
