import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';

/// Modelo concreto de un proveedor tipo DJ.
///
/// OCP → extiende [Proveedor] sin modificar la clase base.
class ProveedorDj extends Proveedor {
  /// Horas de servicio contratadas (afecta el costo final).
  final int horasDeServicio;

  const ProveedorDj({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    this.horasDeServicio = 4,
  }) : super(tipo: TipoProveedor.dj);

  /// Tarifa: costoBase + $50 por cada hora adicional a las 4 horas incluidas.
  @override
  double calcularCostoFinal() {
    const horasIncluidas = 4;
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

/// Fábrica concreta que instancia [ProveedorDj].
/// Factory Method → implementa [ProveedorFactory.crearProveedor].
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