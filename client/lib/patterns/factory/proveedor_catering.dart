// Archivo para el patron factory de proveedor catering.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';




class ProveedorCatering extends Proveedor {
  

// Variable para numero de platillos.
  final int numeroDePlatillos;

  

// Variable para costo por platillo.
  final double costoPorPlatillo;

  const ProveedorCatering({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    required this.numeroDePlatillos,
    this.costoPorPlatillo = 25.0,
  }) : super(tipo: TipoProveedor.catering);

  
  @override
  double calcularCostoFinal() =>
      costoBase + (numeroDePlatillos * costoPorPlatillo);

  @override
  String descripcionServicio() =>
      'Servicio de catering para $numeroDePlatillos comensales. '
      'Incluye entrada, plato fuerte y postre.';
}



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
