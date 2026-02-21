import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_dj.dart';
import 'proveedor_catering.dart';
import 'proveedor_fotografia.dart';

/// Contrato del patrón Factory Method para crear proveedores.
///
/// OCP → nunca se modifica esta clase al agregar un nuevo tipo de proveedor.
/// DIP → los controllers dependen de esta abstracción, no de subclases concretas.
abstract class ProveedorFactory {
  /// Método de fabricación que cada subclase debe implementar.
  Proveedor crearProveedor({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
  });

  /// Factory estático que devuelve la fábrica correcta según el [tipo].
  /// Punto de extensión: agregar un nuevo proveedor solo requiere un nuevo case.
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