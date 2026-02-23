// Archivo para el controlador de boda.



import '../models/boda.dart';
import '../models/invitado.dart';
import '../models/proveedor.dart';
import '../models/evento.dart';
import '../services/invitado_service.dart';
import '../services/proveedor_service.dart';
import '../services/evento_service.dart';
import '../services/presupuesto_service.dart';






class BodaController {

// Variable para invitado servicio.
  final InvitadoService _invitadoService;

// Variable para proveedor servicio.
  final ProveedorService _proveedorService;

// Variable para evento servicio.
  final EventoService _eventoService;

// Variable para presupuesto servicio.
  final PresupuestoService _presupuestoService;


// Variable para boda.
  Boda? _boda;
  Boda? get boda => _boda;

// Variable para on cambio.
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


// Variable para invitados.
    final List<Invitado> invitados = _invitadoService.obtenerTodos();


// Variable para proveedores.
    final List<Proveedor> proveedores = _proveedorService.obtenerTodos();


// Variable para eventos.
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
