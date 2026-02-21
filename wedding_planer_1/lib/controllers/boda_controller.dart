import '../models/boda.dart';
import '../models/invitado.dart';
import '../models/proveedor.dart';
import '../models/evento.dart';
import '../services/invitado_service.dart';
import '../services/proveedor_service.dart';
import '../services/evento_service.dart';
import '../services/presupuesto_service.dart';

/// Coordina el estado general de la boda entre todos los servicios.
/// Actúa como fachada de alto nivel para la pantalla principal.
///
/// SRP  → única responsabilidad: ensamblar el modelo [Boda] con datos frescos
///        de todos los servicios y exponerlo a la pantalla principal.
class BodaController {
  final InvitadoService _invitadoService;
  final ProveedorService _proveedorService;
  final EventoService _eventoService;
  final PresupuestoService _presupuestoService;

  Boda? _boda;
  Boda? get boda => _boda;

  final void Function()? onCambio;

  BodaController({
    required InvitadoService invitadoService,
    required ProveedorService proveedorService,
    required EventoService eventoService,
    required PresupuestoService presupuestoService,
    this.onCambio,
  })  : _invitadoService = invitadoService,
        _proveedorService = proveedorService,
        _eventoService = eventoService,
        _presupuestoService = presupuestoService;

  // ── Inicialización ────────────────────────────────────────────────────────

  /// Inicializa la boda con sus datos base. Llamar una vez al arrancar la app.
  void inicializar({
    required String id,
    required String nombrePareja1,
    required String nombrePareja2,
    required DateTime fechaBoda,
    required String lugarCeremonia,
    required String lugarRecepcion,
  }) {
    _actualizarBoda(
      id: id,
      nombrePareja1: nombrePareja1,
      nombrePareja2: nombrePareja2,
      fechaBoda: fechaBoda,
      lugarCeremonia: lugarCeremonia,
      lugarRecepcion: lugarRecepcion,
    );
  }

  // ── Refresco ──────────────────────────────────────────────────────────────

  /// Reconstruye el modelo [Boda] con el estado actual de todos los servicios.
  void refrescar() {
    if (_boda == null) return;
    _actualizarBoda(
      id: _boda!.id,
      nombrePareja1: _boda!.nombrePareja1,
      nombrePareja2: _boda!.nombrePareja2,
      fechaBoda: _boda!.fechaBoda,
      lugarCeremonia: _boda!.lugarCeremonia,
      lugarRecepcion: _boda!.lugarRecepcion,
    );
  }

  void _actualizarBoda({
    required String id,
    required String nombrePareja1,
    required String nombrePareja2,
    required DateTime fechaBoda,
    required String lugarCeremonia,
    required String lugarRecepcion,
  }) {
    final List<Invitado> invitados = _invitadoService.obtenerTodos();
    final List<Proveedor> proveedores = _proveedorService.obtenerTodos();
    final List<Evento> eventos = _eventoService.obtenerOrdenados();

    _boda = Boda(
      id: id,
      nombrePareja1: nombrePareja1,
      nombrePareja2: nombrePareja2,
      fechaBoda: fechaBoda,
      lugarCeremonia: lugarCeremonia,
      lugarRecepcion: lugarRecepcion,
      invitados: invitados,
      proveedores: proveedores,
      eventos: eventos,
      presupuesto: _presupuestoService.calcular(
        invitados: invitados,
        proveedores: proveedores,
      ),
    );
    onCambio?.call();
  }

  // ── Accesores de conveniencia ─────────────────────────────────────────────

  // ── Eventos (puente UI → EventoService) ───────────────────────────────────

  void crearEvento({
    required String id,
    required String nombre,
    required String lugar,
    required DateTime fechaHora,
    required int duracionMinutos,
    String? descripcion,
  }) {
    _eventoService.crear(
      id: id,
      nombre: nombre,
      lugar: lugar,
      fechaHora: fechaHora,
      duracionMinutos: duracionMinutos,
      descripcion: descripcion,
    );
    refrescar();
  }

  void eliminarEvento(String id) {
    _eventoService.eliminar(id);
    refrescar();
  }
  String get titulo => _boda?.titulo ?? '—';
  int get diasRestantes => _boda?.diasRestantes ?? 0;
  int get totalInvitados => _boda?.totalInvitados ?? 0;
  int get confirmados => _boda?.invitadosConfirmados ?? 0;
}
