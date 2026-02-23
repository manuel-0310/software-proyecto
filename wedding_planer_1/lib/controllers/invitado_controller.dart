// Archivo para el controlador de invitado.



import '../models/invitado.dart';
import '../enums/estado_invitado.dart';
import '../services/invitado_service.dart';






class InvitadoController {

// Variable para servicio.
  final InvitadoService _service;

  


// Variable para invitados.
  List<Invitado> _invitados = [];
  List<Invitado> get invitados => List.unmodifiable(_invitados);

  
// Variable para on cambio.
  final void Function()? onCambio;

  InvitadoController({
    required InvitadoService service,
    this.onCambio,
  }) : _service = service {
    _cargar();
  }

  

  void _cargar() {
    _invitados = _service.obtenerTodos();
    onCambio?.call();
  }

  

  
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

  
  void eliminar(String id) {
    _service.eliminar(id);
    _cargar();
  }

  
  void cambiarEstado(String id, EstadoInvitado nuevoEstado) {
    _service.cambiarEstado(id, nuevoEstado);
    _cargar();
  }

  

  Map<EstadoInvitado, int> get resumenPorEstado =>
      _service.resumenPorEstado();

  List<Invitado> get confirmados => _service.obtenerConfirmados();

  int get total => _invitados.length;
}
