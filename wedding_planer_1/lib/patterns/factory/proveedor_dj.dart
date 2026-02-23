// Archivo para el patron factory de proveedor dj.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';




class ProveedorDj extends Proveedor {
  

// Variable para horas de servicio.
  final int horasDeServicio;

  const ProveedorDj({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    this.horasDeServicio = 4,
  }) : super(tipo: TipoProveedor.dj);

  
  @override
  double calcularCostoFinal() {


// Variable para horas incluidas.
    const horasIncluidas = 4;


// Variable para tarifa hora extra.
    const tarifaHoraExtra = 50.0;
    final horasExtra =
        (horasDeServicio - horasIncluidas).clamp(0, double.infinity);
    return costoBase + (horasExtra * tarifaHoraExtra);
  }

  @override
  String descripcionServicio() =>
      'Servicio de DJ por $horasDeServicio horas. '
      'Incluye equipo de sonido e iluminación.';
}



class DjFactory extends ProveedorFactory {
  @override
  ProveedorDj crearProveedor({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
    int horasDeServicio = 4,
  }) {
    return ProveedorDj(
      id: id,
      nombre: nombre,
      contacto: contacto,
      costoBase: costoBase,
      horasDeServicio: horasDeServicio,
    );
  }
}
