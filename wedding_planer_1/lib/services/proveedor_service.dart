// Archivo para el servicio de proveedor.



import '../models/proveedor.dart';
import '../enums/tipo_proveedor.dart';
import '../repositories/interfaces/i_proveedor_repository.dart';





class ProveedorService {

// Variable para repositorio.
  final IProveedorRepository _repository;

  const ProveedorService({required IProveedorRepository repository})
      : _repository = repository;

  

  
  void contratar(Proveedor proveedor) => _repository.guardar(proveedor);

  
  void cancelar(String id) => _repository.eliminar(id);

  
  List<Proveedor> obtenerTodos() => _repository.obtenerTodos();

  
  Proveedor? obtenerPorId(String id) => _repository.obtenerPorId(id);

  

  
  List<Proveedor> obtenerPorTipo(TipoProveedor tipo) =>
      obtenerTodos().where((p) => p.tipo == tipo).toList();

  
  Proveedor? masEconomico(TipoProveedor tipo) {


// Variable para lista.
    final lista = obtenerPorTipo(tipo);
    if (lista.isEmpty) return null;
    return lista.reduce(
      (a, b) => a.calcularCostoFinal() <= b.calcularCostoFinal() ? a : b,
    );
  }

  
  double costoTotalProveedores() => obtenerTodos().fold(
        0.0,
        (sum, p) => sum + p.calcularCostoFinal(),
      );
}
