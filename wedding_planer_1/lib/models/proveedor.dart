// Archivo para el modelo de proveedor.



import '../enums/tipo_proveedor.dart';






abstract class Proveedor {

// Variable para id.
  final String id;

// Variable para nombre.
  final String nombre;

// Variable para contacto.
  final String contacto;

// Variable para costo base.
  final double costoBase;

// Variable para tipo.
  final TipoProveedor tipo;

  const Proveedor({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.costoBase,
    required this.tipo,
  });

  
  
  double calcularCostoFinal();

  
  String descripcionServicio();

  @override
  String toString() =>
      '${tipo.nombre} — $nombre | \$${calcularCostoFinal().toStringAsFixed(2)}';
}
