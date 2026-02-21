import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';

/// Modelo concreto de un proveedor tipo Catering.
///
/// OCP → extiende [Proveedor] sin modificar la clase base.
class ProveedorCatering extends Proveedor {
  /// Número de comensales confirmados (determina el costo final).
  final int numeroDePlatillos;

  /// Costo por platillo adicional al costo base.
  final double costoPorPlatillo;

  const ProveedorCatering({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    required this.numeroDePlatillos,
    this.costoPorPlatillo = 25.0,
  }) : super(tipo: TipoProveedor.catering);

  /// Tarifa: costoBase + (platillos × costoPorPlatillo).
  @override
  double calcularCostoFinal() =>
      costoBase + (numeroDePlatillos * costoPorPlatillo);

  @override
  String descripcionServicio() =>
      'Servicio de catering para $numeroDePlatillos comensales. '
      'Incluye entrada, plato fuerte y postre.';
}

/// Fábrica concreta que instancia [ProveedorCatering].
/// Factory Method → implementa [ProveedorFactory.crearProveedor].
class CateringFactory extends ProveedorFactory {
  @override
  ProveedorCatering crearProveedor({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
    int numeroDePlatillos = 50,
    double costoPorPlatillo = 25.0,
  }) {
    return ProveedorCatering(
      id: id,
      nombre: nombre,
      contacto: contacto,
      costoBase: costoBase,
      numeroDePlatillos: numeroDePlatillos,
      costoPorPlatillo: costoPorPlatillo,
    );
  }
}