// Archivo para el enum de tipo proveedor.




enum TipoProveedor {
  dj,
  catering,
  fotografia;

  
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
