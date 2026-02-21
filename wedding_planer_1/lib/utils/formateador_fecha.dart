/// Helpers estáticos para formatear fechas y duraciones en la UI.
///
/// SRP  → única responsabilidad: transformar [DateTime] y duraciones en
///        cadenas legibles para el usuario. Sin lógica de negocio.
///
/// No depende de ningún paquete externo para mantener el proyecto liviano.
/// Si en el futuro se requiere localización avanzada, se puede sustituir
/// por `intl` sin modificar ningún otro archivo (OCP).
class FormateadorFecha {
  // Constructor privado: solo métodos estáticos.
  FormateadorFecha._();

  // ── Formatos de fecha ─────────────────────────────────────────────────────

  /// Retorna la fecha en formato largo: "sábado, 14 de junio de 2025".
  static String largo(DateTime fecha) {
    const dias = [
      'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo',
    ];
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final dia = dias[fecha.weekday - 1];
    final mes = meses[fecha.month];
    return '$dia, ${fecha.day} de $mes de ${fecha.year}';
  }

  /// Retorna la fecha en formato corto: "14/06/2025".
  static String corto(DateTime fecha) =>
      '${_dos(fecha.day)}/${_dos(fecha.month)}/${fecha.year}';

  /// Retorna solo la hora en formato 12 h: "03:30 PM".
  static String hora(DateTime fecha) {
    final h = fecha.hour;
    final m = _dos(fecha.minute);
    final periodo = h >= 12 ? 'PM' : 'AM';
    final hora12 = h % 12 == 0 ? 12 : h % 12;
    return '$hora12:$m $periodo';
  }

  /// Retorna fecha y hora: "14/06/2025 — 03:30 PM".
  static String fechaYHora(DateTime fecha) =>
      '${corto(fecha)} — ${hora(fecha)}';

  // ── Cuenta regresiva ──────────────────────────────────────────────────────

  /// Días restantes hasta [fecha] desde hoy.
  /// Retorna 0 si la fecha ya pasó.
  static int diasRestantes(DateTime fecha) {
    final hoy = DateTime.now();
    final diferencia = fecha.difference(hoy).inDays;
    return diferencia < 0 ? 0 : diferencia;
  }

  /// Texto de cuenta regresiva listo para mostrar en la UI.
  /// Ejemplos: "Faltan 45 días", "¡Es hoy!", "La boda ya ocurrió".
  static String cuentaRegresiva(DateTime fecha) {
    final dias = diasRestantes(fecha);
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

  // ── Duración ──────────────────────────────────────────────────────────────

  /// Convierte minutos en texto legible: "1 h 30 min" o "45 min".
  static String duracion(int minutos) {
    if (minutos <= 0) return '0 min';
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  // ── Helper interno ────────────────────────────────────────────────────────

  /// Garantiza siempre dos dígitos: 5 → "05".
  static String _dos(int valor) => valor.toString().padLeft(2, '0');
}