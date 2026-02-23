// Archivo para la interfaz del repositorio de invitado.



import '../../models/invitado.dart';







abstract class IInvitadoRepository {
  
  void guardar(Invitado invitado);

  
  void eliminar(String id);

  
  List<Invitado> obtenerTodos();

  
  Invitado? obtenerPorId(String id);
}
