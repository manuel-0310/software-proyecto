// Archivo para la implementacion del repositorio de invitado.



import '../../models/invitado.dart';
import '../../data/local/invitado_datasource.dart';
import '../interfaces/i_invitado_repository.dart';








class InvitadoRepositoryImpl implements IInvitadoRepository {

// Variable para datasource.
  final InvitadoDatasource _datasource;

  const InvitadoRepositoryImpl({required InvitadoDatasource datasource})
      : _datasource = datasource;

  @override
  void guardar(Invitado invitado) => _datasource.guardar(invitado);

  @override
  void eliminar(String id) => _datasource.eliminar(id);

  @override
  List<Invitado> obtenerTodos() => _datasource.obtenerTodos();

  @override
  Invitado? obtenerPorId(String id) => _datasource.obtenerPorId(id);
}
