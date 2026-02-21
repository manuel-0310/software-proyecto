import '../../models/invitado.dart';

/// Contrato abstracto para la persistencia de invitados.
///
/// DIP  → [InvitadoService] depende de esta interfaz, nunca de la implementación
///        concreta. Se puede cambiar el motor de persistencia sin tocar servicios.
/// OCP  → agregar una nueva implementación (SQLite, Firebase, etc.) no requiere
///        modificar nada que ya existe.
abstract class IInvitadoRepository {
  /// Guarda o actualiza un [invitado] (upsert por id).
  void guardar(Invitado invitado);

  /// Elimina el invitado con [id]. No lanza error si no existe.
  void eliminar(String id);

  /// Retorna todos los invitados registrados.
  List<Invitado> obtenerTodos();

  /// Retorna el invitado con [id], o `null` si no existe.
  Invitado? obtenerPorId(String id);
}