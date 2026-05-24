// Archivo para el controlador de invitado (Servicio Consumidor → Weddy API).

import '../data/remote/invitado_remote_datasource.dart';
import '../enums/estado_invitado.dart';
import '../models/invitado.dart';
import '../patterns/circuit_breaker/circuit_breaker.dart';
import '../services/invitado_service.dart';

class InvitadoController {

// Variable para servicio (caché local, compartida con BodaController).
  final InvitadoService _service;

// Variable para datasource remoto con Circuit Breaker incorporado.
  final InvitadoRemoteDatasource _remote;

// Variable para invitados.
  List<Invitado> _invitados = [];
  List<Invitado> get invitados => List.unmodifiable(_invitados);

// Estado del Circuit Breaker visible para la UI.
  bool _circuitoAbierto = false;
  bool get circuitoAbierto => _circuitoAbierto;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

// Variable para on cambio.
  final void Function()? onCambio;

  InvitadoController({
    required InvitadoService service,
    required InvitadoRemoteDatasource remote,
    this.onCambio,
  })  : _service = service,
        _remote = remote;

  // ── Carga inicial ────────────────────────────────────────────────────────

  /// Obtiene la lista desde la Weddy API y actualiza la caché local.
  /// Si el circuito está OPEN y hay caché, usa datos cacheados (degradación elegante).
  /// Si no hay caché y el circuito está OPEN, expone [mensajeError] a la UI.
  Future<void> cargar() async {
    try {
      final lista = await _remote.obtenerTodos();
      _service.sincronizar(lista);
      _invitados = _service.obtenerTodos();
      _circuitoAbierto = false;
      _mensajeError = null;
    } on CircuitBreakerException catch (e) {
      _circuitoAbierto = true;
      _mensajeError = e.message;
      // Si ya hay caché local, la UI puede seguir mostrando datos.
      _invitados = _service.obtenerTodos();
    } catch (e) {
      _circuitoAbierto = _remote.circuitoAbierto;
      _mensajeError = 'Error al conectar con el servidor. Verifica tu red.';
    } finally {
      onCambio?.call();
    }
  }

  // ── Escritura (POST protegido con JWT en el backend) ─────────────────────
  // TODO(JWT): Los métodos de escritura usan endpoints protegidos.
  //            El ApiClient ya incluye el header Authorization. Ver api_client.dart.

  /// Crea un invitado vía POST /invitados/ y recarga la lista.
  /// Lanza [CircuitBreakerException] si el circuito está abierto (sin degradación:
  /// no tendría sentido crear datos en caché sin confirmar que se guardaron).
  Future<void> agregar({
    required String nombre,
    required String apellido,
    required String correo,
    String? telefono,
    int? mesaAsignada,
  }) async {
    await _remote.crear(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      mesaAsignada: mesaAsignada,
    );
    await cargar();
  }

  /// Elimina un invitado vía DELETE /invitados/{id}.
  Future<void> eliminar(String id) async {
    await _remote.eliminar(id);
    await cargar();
  }

  /// Actualiza el estado vía PATCH /invitados/{id}/estado.
  Future<void> cambiarEstado(String id, EstadoInvitado nuevoEstado) async {
    await _remote.actualizarEstado(id, nuevoEstado);
    await cargar();
  }

  /// Reinicia el circuito manualmente y recarga.
  Future<void> reintentar() async {
    _remote.resetCircuito();
    await cargar();
  }

  // ── Getters síncronos (leen de la caché local) ───────────────────────────

  Map<EstadoInvitado, int> get resumenPorEstado => _service.resumenPorEstado();

  List<Invitado> get confirmados => _service.obtenerConfirmados();

  int get total => _invitados.length;
}
