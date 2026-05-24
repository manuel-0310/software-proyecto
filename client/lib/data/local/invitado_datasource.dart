// Archivo para el datasource local de invitado.



import '../../models/invitado.dart';









class InvitadoDatasource {
  


// Variable para almacen.
  final Map<String, Invitado> _almacen = {};

  

  
  void guardar(Invitado invitado) {
    _almacen[invitado.id] = invitado;
  }

  
  void eliminar(String id) => _almacen.remove(id);

  
  List<Invitado> obtenerTodos() => List.unmodifiable(_almacen.values.toList());

  
  Invitado? obtenerPorId(String id) => _almacen[id];

  
  int get cantidad => _almacen.length;

  
  void limpiar() => _almacen.clear();
}
