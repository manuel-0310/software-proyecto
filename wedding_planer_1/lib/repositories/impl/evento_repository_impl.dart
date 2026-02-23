// Archivo para la implementacion del repositorio de evento.



import '../../models/evento.dart';
import '../../enums/estado_evento.dart';
import '../../data/local/evento_datasource.dart';
import '../interfaces/i_evento_repository.dart';








class EventoRepositoryImpl implements IEventoRepository {

// Variable para datasource.
  final EventoDatasource _datasource;

  const EventoRepositoryImpl({required EventoDatasource datasource})
      : _datasource = datasource;

  @override
  void guardar(Evento evento) => _datasource.guardar(evento);

  @override
  void eliminar(String id) => _datasource.eliminar(id);

  @override
  List<Evento> obtenerTodos() => _datasource.obtenerTodos();

  @override
  Evento? obtenerPorId(String id) => _datasource.obtenerPorId(id);

  @override
  List<Evento> obtenerPorEstado(EstadoEvento estado) =>
      _datasource.obtenerPorEstado(estado);

  @override
  List<Evento> obtenerOrdenados() => _datasource.obtenerOrdenados();
}
