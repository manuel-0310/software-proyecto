// Archivo para el datasource local de evento.



import '../../models/evento.dart';
import '../../enums/estado_evento.dart';





class EventoDatasource {
  


// Variable para almacen.
  final Map<String, Evento> _almacen = {};

  

  
  void guardar(Evento evento) {
    _almacen[evento.id] = evento;
  }

  
  void eliminar(String id) => _almacen.remove(id);

  
  List<Evento> obtenerTodos() =>
      List.unmodifiable(_almacen.values.toList());

  
  Evento? obtenerPorId(String id) => _almacen[id];

  
  List<Evento> obtenerPorEstado(EstadoEvento estado) =>
      _almacen.values.where((e) => e.estado == estado).toList();

  
  List<Evento> obtenerOrdenados() {


// Variable para lista.
    final lista = _almacen.values.toList();
    lista.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return lista;
  }

  
  int get cantidad => _almacen.length;

  
  void limpiar() => _almacen.clear();
}
