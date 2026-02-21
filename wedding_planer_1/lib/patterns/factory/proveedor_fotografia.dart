import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';

/// Modelo concreto de un proveedor tipo Fotografía.
///
/// OCP → extiende [Proveedor] sin modificar la clase base.
class ProveedorFotografia extends Proveedor {
  /// Si el paquete incluye sesión de video además de fotografía.
  final bool incluyeVideo;

  /// Número de horas de cobertura del evento.
  final int horasCobertura;

  const ProveedorFotografia({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    required this.horasCobertura,
    this.incluyeVideo = false,
  }) : super(tipo: TipoProveedor.fotografia);

  /// Tarifa: costoBase + 20% si incluye video + $40 por hora de cobertura.
  @override
  double calcularCostoFinal() {
    const tarifaPorHora = 40.0;
    final recargoPorVideo = incluyeVideo ? costoBase * 0.20 : 0.0;
    return costoBase + recargoPorVideo + (horasCobertura * tarifaPorHora);
  }

  @override
  String descripcionServicio() {
    final extras = incluyeVideo ? 'Fotografía + Video' : 'Solo fotografía';
    return '$extras — cobertura de $horasCobertura horas. '
        'Entrega de álbum digital y físico.';
  }
}

/// Fábrica concreta que instancia [ProveedorFotografia].
/// Factory Method → implementa [ProveedorFactory.crearProveedor].
class FotografiaFactory extends ProveedorFactory {
  @override
  ProveedorFotografia crearProveedor({
    required String id,
    required String nombre,
    required String contacto,
    required double costoBase,
    int horasCobertura = 6,
    bool incluyeVideo = false,
  }) {
    return ProveedorFotografia(
      id: id,
      nombre: nombre,
      contacto: contacto,
      costoBase: costoBase,
      horasCobertura: horasCobertura,
      incluyeVideo: incluyeVideo,
    );
  }
}