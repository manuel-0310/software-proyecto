import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cliente HTTP centralizado para comunicarse con la Weddy API (Servicio Proveedor).
///
/// Cambia [baseUrl] si ejecutas el backend en un host distinto.
/// En Android Emulator usa 'http://10.0.2.2:8000'.
/// En iOS Simulator / desktop usa 'http://localhost:8000'.
class ApiClient {
  static const String baseUrl = 'http://172.20.10.6:8000';

  // TODO(JWT): Implementa almacenamiento del token aquí. Ejemplo:
  //   static String? _token;
  //   static void setToken(String t) => _token = t;
  //   Luego úsalo en _headers: headers['Authorization'] = 'Bearer $_token';

  /// Encabezados comunes para peticiones públicas (sin autenticación).
  static Map<String, String> get _headers {
    return {'Content-Type': 'application/json'};
  }

  /// Encabezados que incluyen el token JWT (para endpoints protegidos).
  static Map<String, String> get _authHeaders {
    final headers = <String, String>{'Content-Type': 'application/json'};
    // TODO(JWT): Reemplaza el token hardcoded por el token guardado en sesión.
    // En producción, obtén el token via POST /auth/login y guárdalo de forma segura.
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc3NjI5ODAyNn0.v4enAOMoZ2V6GvUKYbMxzBZUcXM2xku4najl_0rvFek';
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // ── Métodos GET (sin autenticación) ─────────────────────────────────────

  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  // ── Métodos POST (con autenticación Bearer) ──────────────────────────────

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _authHeaders,
      body: jsonEncode(body),
    );
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  // ── Métodos PATCH (con autenticación Bearer) ─────────────────────────────

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: _authHeaders,
      body: jsonEncode(body),
    );
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  // ── Métodos DELETE (con autenticación Bearer) ────────────────────────────

  static Future<void> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: _authHeaders);
    if (response.statusCode != 204 && response.statusCode ~/ 100 != 2) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static void _checkStatus(http.Response response) {
    if (response.statusCode ~/ 100 != 2) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  const ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
