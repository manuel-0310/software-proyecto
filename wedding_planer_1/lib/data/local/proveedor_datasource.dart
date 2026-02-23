// Archivo para el datasource local de proveedor.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';





class ProveedorDatasource {
  


// Variable para almacen.
  final Map<String, Proveedor> _almacen = {};

  

  
  void guardar(Proveedor proveedor) {
    _almacen[proveedor.id] = proveedor;
  }

  
  void eliminar(String id) => _almacen.remove(id);

  
  List<Proveedor> obtenerTodos() =>
      List.unmodifiable(_almacen.values.toList());

  
  Proveedor? obtenerPorId(String id) => _almacen[id];

  
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo) =>
      _almacen.values.where((p) => p.tipo == tipo).toList();

  
  int get cantidad => _almacen.length;

  
  void limpiar() => _almacen.clear();
}
