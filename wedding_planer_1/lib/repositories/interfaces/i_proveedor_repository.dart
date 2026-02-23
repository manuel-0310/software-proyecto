// Archivo para la interfaz del repositorio de proveedor.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';






abstract class IProveedorRepository {
  
  void guardar(Proveedor proveedor);

  
  void eliminar(String id);

  
  List<Proveedor> obtenerTodos();

  
  Proveedor? obtenerPorId(String id);

  
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo);
}
