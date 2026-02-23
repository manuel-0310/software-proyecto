// Archivo para la interfaz del repositorio de evento.



import '../../models/evento.dart';
import '../../enums/estado_evento.dart';






abstract class IEventoRepository {
  
  void guardar(Evento evento);

  
  void eliminar(String id);

  
  List<Evento> obtenerTodos();

  
  Evento? obtenerPorId(String id);

  
  List<Evento> obtenerPorEstado(EstadoEvento estado);

  
  List<Evento> obtenerOrdenados();
}
