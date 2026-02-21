import '../models/invitado.dart';
import '../enums/estado_invitado.dart';
import '../services/invitado_service.dart';

/// Intermediario entre la UI y [InvitadoService].
/// Gestiona el estado reactivo de la lista de invitados para las pantallas.
///
/// SRP  → única responsabilidad: coordinar la UI con la lógica de invitados.
/// DIP  → depende de [InvitadoService] (abstracción de negocio), no de repos.
class InvitadoController {
  final InvitadoService _service;

  /// Lista observable de invitados. La UI escucha cambios aquí.
  List<Invitado> _invitados = [];
  List<Invitado> get invitados => List.unmodifiable(_invitados);

  /// Callback para notificar a la UI cuando el estado cambia.
  final void Function()? onCambio;

  InvitadoController({
    required InvitadoService service,
    this.onCambio,
  }) : _service = service {
    _cargar();
  }

  // ── Inicialización ────────────────────────────────────────────────────────

  void _cargar() {
    _invitados = _service.obtenerTodos();
    onCambio?.call();
  }

  // ── Acciones desde la UI ──────────────────────────────────────────────────

  /// Agrega un nuevo invitado y refresca la lista.
  void agregar({
    required String id,
    required String nombre,
    required String apellido,
    required String correo,
    String? telefono,
    int? mesaAsignada,
  }) {
    _service.agregar(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      mesaAsignada: mesaAsignada,
    );
    _cargar();
  }

  /// Elimina un invitado por [id] y refresca la lista.
  void eliminar(String id) {
    _service.eliminar(id);
    _cargar();
  }

  /// Cambia el estado de un invitado (dispara Observer internamente).
  void cambiarEstado(String id, EstadoInvitado nuevoEstado) {
    _service.cambiarEstado(id, nuevoEstado);
    _cargar();
  }

  // ── Consultas para la UI ──────────────────────────────────────────────────

  Map<EstadoInvitado, int> get resumenPorEstado =>
      _service.resumenPorEstado();

  List<Invitado> get confirmados => _service.obtenerConfirmados();

  int get total => _invitados.length;
}