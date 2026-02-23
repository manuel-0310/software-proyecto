// Archivo para el controlador de presupuesto.



import '../models/presupuesto.dart';
import '../services/presupuesto_service.dart';
import '../services/invitado_service.dart';
import '../services/proveedor_service.dart';







class PresupuestoController {

// Variable para presupuesto servicio.
  final PresupuestoService _presupuestoService;

// Variable para invitado servicio.
  final InvitadoService _invitadoService;

// Variable para proveedor servicio.
  final ProveedorService _proveedorService;


// Variable para presupuesto.
  Presupuesto? _presupuesto;
  Presupuesto? get presupuesto => _presupuesto;

// Variable para on cambio.
  final void Function()? onCambio;

  PresupuestoController({
    required PresupuestoService presupuestoService,
    required InvitadoService invitadoService,
    required ProveedorService proveedorService,
    this.onCambio,
  })  : _presupuestoService = presupuestoService,
        _invitadoService = invitadoService,
        _proveedorService = proveedorService {
    recalcular();
  }

  

  
  
  void recalcular() {
    _presupuesto = _presupuestoService.calcular(
      invitados: _invitadoService.obtenerTodos(),
      proveedores: _proveedorService.obtenerTodos(),
    );
    onCambio?.call();
  }

  

  bool get estaExcedido =>
      _presupuesto != null &&
      _presupuestoService.estaExcedido(_presupuesto!);

  bool get cercaDelLimite =>
      _presupuesto != null &&
      _presupuestoService.cercaDelLimite(_presupuesto!);

  double get costoTotal => _presupuesto?.costoTotal ?? 0.0;

  double get saldoRestante => _presupuesto?.saldoRestante ?? 0.0;

  double get porcentajeUtilizado =>
      _presupuesto?.porcentajeUtilizado ?? 0.0;

  String get resumenTexto => _presupuesto != null
      ? _presupuestoService.resumenTexto(_presupuesto!)
      : 'Sin datos de presupuesto.';
}
