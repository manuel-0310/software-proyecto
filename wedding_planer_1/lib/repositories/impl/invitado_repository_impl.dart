import '../../models/invitado.dart';
import '../../data/local/invitado_datasource.dart';
import '../interfaces/i_invitado_repository.dart';

/// Implementación concreta del repositorio de invitados.
/// Usa [InvitadoDatasource] como fuente de datos local (en memoria).
///
/// DIP  → implementa [IInvitadoRepository]; el servicio nunca sabe qué motor
///        de persistencia está usando realmente.
/// SRP  → única responsabilidad: traducir las llamadas del servicio en
///        operaciones sobre el datasource.
class InvitadoRepositoryImpl implements IInvitadoRepository {
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