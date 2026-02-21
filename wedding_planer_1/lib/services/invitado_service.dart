import '../models/invitado.dart';
import '../enums/estado_invitado.dart';
import '../repositories/interfaces/i_invitado_repository.dart';
import '../patterns/observer/invitado_observer.dart';

/// Lógica de negocio exclusiva para la gestión de invitados.
///
/// SRP  → única responsabilidad: operaciones de negocio sobre invitados.
/// DIP  → depende de [IInvitadoRepository] (interfaz), no de la implementación.
class InvitadoService {
  final IInvitadoRepository _repository;

  /// Observadores que se suscriben automáticamente a cada invitado creado.
  final List<InvitadoObserver> _observadoresGlobales;

  InvitadoService({
    required IInvitadoRepository repository,
    List<InvitadoObserver> observadoresGlobales = const [],
  })  : _repository = repository,
        _observadoresGlobales = observadoresGlobales;

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Crea y persiste un nuevo invitado; le adjunta los observadores globales.
  Invitado agregar({
    required String id,
    required String nombre,
    required String apellido,
    required String correo,
    String? telefono,
    int? mesaAsignada,
  }) {
    final invitado = Invitado(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      mesaAsignada: mesaAsignada,
    );

    for (final obs in _observadoresGlobales) {
      invitado.suscribir(obs);
    }

    _repository.guardar(invitado);
    return invitado;
  }

  /// Elimina un invitado por [id].
  void eliminar(String id) => _repository.eliminar(id);

  /// Retorna todos los invitados persistidos.
  List<Invitado> obtenerTodos() => _repository.obtenerTodos();

  /// Retorna un invitado por [id], o `null` si no existe.
  Invitado? obtenerPorId(String id) => _repository.obtenerPorId(id);

  // ── Lógica de negocio ─────────────────────────────────────────────────────

  /// Cambia el estado de un invitado y dispara el Observer automáticamente.
  void cambiarEstado(String id, EstadoInvitado nuevoEstado) {
    final invitado = _repository.obtenerPorId(id);
    if (invitado == null) {
      throw StateError('Invitado con id "$id" no encontrado.');
    }
    invitado.cambiarEstado(nuevoEstado); // notifica a sus observers internamente
    _repository.guardar(invitado);
  }

  /// Retorna solo los invitados con estado [EstadoInvitado.confirmado].
  List<Invitado> obtenerConfirmados() => obtenerTodos()
      .where((i) => i.estado == EstadoInvitado.confirmado)
      .toList();

  /// Retorna el conteo agrupado por estado.
  Map<EstadoInvitado, int> resumenPorEstado() {
    final todos = obtenerTodos();
    return {
      for (final estado in EstadoInvitado.values)
        estado: todos.where((i) => i.estado == estado).length,
    };
  }
}