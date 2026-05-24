// Archivo para la utilidad de formateador fecha.










class FormateadorFecha {
  
  FormateadorFecha._();

  

  
  static String largo(DateTime fecha) {
    const dias = [
      'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo',
    ];
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];


// Variable para dia.
    final dia = dias[fecha.weekday - 1];


// Variable para mes.
    final mes = meses[fecha.month];
    return '$dia, ${fecha.day} de $mes de ${fecha.year}';
  }

  
  static String corto(DateTime fecha) =>
      '${_dos(fecha.day)}/${_dos(fecha.month)}/${fecha.year}';

  
  static String hora(DateTime fecha) {


// Variable para h.
    final h = fecha.hour;


// Variable para m.
    final m = _dos(fecha.minute);


// Variable para periodo.
    final periodo = h >= 12 ? 'PM' : 'AM';


// Variable para hora12.
    final hora12 = h % 12 == 0 ? 12 : h % 12;
    return '$hora12:$m $periodo';
  }

  
  static String fechaYHora(DateTime fecha) =>
      '${corto(fecha)} — ${hora(fecha)}';

  

  
  
  static int diasRestantes(DateTime fecha) {


// Variable para hoy.
    final hoy = DateTime.now();


// Variable para diferencia.
    final diferencia = fecha.difference(hoy).inDays;
    return diferencia < 0 ? 0 : diferencia;
  }

  
  
  static String cuentaRegresiva(DateTime fecha) {


// Variable para dias.
    final dias = diasRestantes(fecha);


// Variable para hoy.
    final hoy = DateTime.now();

    if (fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day) {
      return '¡Es hoy! 🎉';
    }
    if (fecha.isBefore(hoy)) return 'La boda ya ocurrió';
    if (dias == 1) return 'Falta 1 día';
    return 'Faltan $dias días';
  }

  

  
  static String duracion(int minutos) {
    if (minutos <= 0) return '0 min';


// Variable para h.
    final h = minutos ~/ 60;


// Variable para m.
    final m = minutos % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  

  
  static String _dos(int valor) => valor.toString().padLeft(2, '0');
}
