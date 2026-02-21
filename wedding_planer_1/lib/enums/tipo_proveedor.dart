/// Define los tipos de proveedor disponibles para contratar en la boda.
/// Usado por el Factory Method para instanciar la subclase correcta.
enum TipoProveedor {
  dj,
  catering,
  fotografia;

  /// Nombre descriptivo del tipo de proveedor.
  String get nombre {
    switch (this) {
      case TipoProveedor.dj:
        return 'DJ';
      case TipoProveedor.catering:
        return 'Catering';
      case TipoProveedor.fotografia:
        return 'Fotografía';
    }
  }
}