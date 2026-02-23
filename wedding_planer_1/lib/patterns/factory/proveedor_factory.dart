// Archivo para el patron factory de proveedor.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_dj.dart';
import 'proveedor_catering.dart';
import 'proveedor_fotografia.dart';





abstract class ProveedorFactory {
  
  Proveedor crearProveedor({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
  });

  
  
  static ProveedorFactory segunTipo(TipoProveedor tipo) {
    switch (tipo) {
      case TipoProveedor.dj:
        return DjFactory();
      case TipoProveedor.catering:
        return CateringFactory();
      case TipoProveedor.fotografia:
        return FotografiaFactory();
    }
  }
}
