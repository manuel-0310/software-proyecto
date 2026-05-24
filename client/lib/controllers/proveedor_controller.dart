// Archivo para el controlador de proveedor.



import '../models/proveedor.dart';
import '../enums/tipo_proveedor.dart';
import '../services/proveedor_service.dart';
import '../patterns/factory/proveedor_factory.dart';
import '../patterns/factory/proveedor_dj.dart';
import '../patterns/factory/proveedor_catering.dart';
import '../patterns/factory/proveedor_fotografia.dart';







class ProveedorController {

// Variable para servicio.
  final ProveedorService _service;



// Variable para proveedores.
  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => List.unmodifiable(_proveedores);

// Variable para on cambio.
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

  

  
  
  void contratar({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
    required TipoProveedor tipo,
    Map<String, dynamic> extras = const {},
  }) {


// Variable para factory.
    final factory = ProveedorFactory.segunTipo(tipo);

// Variable para proveedor.
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

  
  void cancelar(String id) {
    _service.cancelar(id);
    _cargar();
  }

  

  List<Proveedor> porTipo(TipoProveedor tipo) =>
      _service.obtenerPorTipo(tipo);

  double get costoTotal => _service.costoTotalProveedores();
}
