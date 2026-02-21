import '../enums/tipo_proveedor.dart';

/// Clase base abstracta para todos los proveedores de la boda.
///
/// OCP → cada tipo de proveedor extiende esta clase sin modificarla.
/// DIP → los servicios y controllers dependen de [Proveedor], no de subclases.
/// Factory Method → las subclases concretas son instanciadas por [ProveedorFactory].
abstract class Proveedor {
  final String id;
  final String nombre;
  final String contacto;
  final double costoBase;
  final TipoProveedor tipo;

  const Proveedor({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.costoBase,
    required this.tipo,
  });

  /// Costo final del proveedor.
  /// Las subclases pueden sobreescribir si aplican tarifas adicionales.
  double calcularCostoFinal();

  /// Descripción del servicio que ofrece este proveedor.
  String descripcionServicio();

  @override
  String toString() =>
      '${tipo.nombre} — $nombre | \$${calcularCostoFinal().toStringAsFixed(2)}';
}