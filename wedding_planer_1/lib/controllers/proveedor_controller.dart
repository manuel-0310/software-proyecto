import '../models/proveedor.dart';
import '../enums/tipo_proveedor.dart';
import '../services/proveedor_service.dart';
import '../patterns/factory/proveedor_factory.dart';
import '../patterns/factory/proveedor_dj.dart';
import '../patterns/factory/proveedor_catering.dart';
import '../patterns/factory/proveedor_fotografia.dart';

/// Intermediario entre la UI y [ProveedorService].
/// Es el punto de integración del patrón Factory Method:
/// la UI solo indica el tipo y los datos; el controller crea el objeto correcto.
///
/// SRP  → coordina la UI con la lógica de proveedores.
/// DIP  → depende de [ProveedorService] y [ProveedorFactory] (abstracciones).
class ProveedorController {
  final ProveedorService _service;

  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => List.unmodifiable(_proveedores);

  final void Function()? onCambio;

  ProveedorController({
    required ProveedorService service,
    this.onCambio,
  }) : _service = service {
    _cargar();
  }

  void _cargar() {
    _proveedores = _service.obtenerTodos();
    onCambio?.call();
  }

  // ── Contratación vía Factory Method ───────────────────────────────────────

  /// Contrata un proveedor usando la Factory correcta según [tipo].
  /// Los parámetros extra se pasan como mapa para mantener firma genérica.
  void contratar({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
    required TipoProveedor tipo,
    Map<String, dynamic> extras = const {},
  }) {
    final factory = ProveedorFactory.segunTipo(tipo);
    late Proveedor proveedor;

    switch (tipo) {
      case TipoProveedor.dj:
        proveedor = (factory as DjFactory).crearProveedor(
          id: id,
          nombre: nombre,
          contacto: contacto,
          costoBase: costoBase,
          horasDeServicio: extras['horasDeServicio'] ?? 4,
        );
      case TipoProveedor.catering:
        proveedor = (factory as CateringFactory).crearProveedor(
          id: id,
          nombre: nombre,
          contacto: contacto,
          costoBase: costoBase,
          numeroDePlatillos: extras['numeroDePlatillos'] ?? 50,
          costoPorPlatillo: extras['costoPorPlatillo'] ?? 25.0,
        );
      case TipoProveedor.fotografia:
        proveedor = (factory as FotografiaFactory).crearProveedor(
          id: id,
          nombre: nombre,
          contacto: contacto,
          costoBase: costoBase,
          horasCobertura: extras['horasCobertura'] ?? 6,
          incluyeVideo: extras['incluyeVideo'] ?? false,
        );
    }

    _service.contratar(proveedor);
    _cargar();
  }

  /// Cancela el contrato con el proveedor identificado por [id].
  void cancelar(String id) {
    _service.cancelar(id);
    _cargar();
  }

  // ── Consultas para la UI ──────────────────────────────────────────────────

  List<Proveedor> porTipo(TipoProveedor tipo) =>
      _service.obtenerPorTipo(tipo);

  double get costoTotal => _service.costoTotalProveedores();
}