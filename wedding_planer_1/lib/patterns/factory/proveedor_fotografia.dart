// Archivo para el patron factory de proveedor fotografia.



import '../../models/proveedor.dart';
import '../../enums/tipo_proveedor.dart';
import 'proveedor_factory.dart';




class ProveedorFotografia extends Proveedor {
  

// Variable para incluye video.
  final bool incluyeVideo;

  

// Variable para horas cobertura.
  final int horasCobertura;

  const ProveedorFotografia({
    required super.id,
    required super.nombre,
    required super.contacto,
    required super.costoBase,
    required this.horasCobertura,
    this.incluyeVideo = false,
  }) : super(tipo: TipoProveedor.fotografia);

  
  @override
  double calcularCostoFinal() {


// Variable para tarifa por hora.
    const tarifaPorHora = 40.0;


// Variable para recargo por video.
    final recargoPorVideo = incluyeVideo ? costoBase * 0.20 : 0.0;
    return costoBase + recargoPorVideo + (horasCobertura * tarifaPorHora);
  }

  @override
  String descripcionServicio() {


// Variable para extras.
    final extras = incluyeVideo ? 'Fotografía + Video' : 'Solo fotografía';
    return '$extras — cobertura de $horasCobertura horas. '
        'Entrega de álbum digital y físico.';
  }
}



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
