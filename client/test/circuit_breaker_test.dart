// Proyecto: Weddy - Wedding Planner
// Entrega 3 - Diseño y Arquitectura de Software
// Pruebas unitarias: Patrón Circuit Breaker

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planer_1/patterns/circuit_breaker/circuit_breaker.dart';

void main() {
  group('CircuitBreaker — estado inicial', () {
    late CircuitBreaker cb;

    setUp(() {
      cb = CircuitBreaker(
        name: 'weddy-api',
        failureThreshold: 3,
        resetTimeout: const Duration(seconds: 30),
      );
    });

    test('el estado inicial es CLOSED', () {
      expect(cb.state, CircuitState.closed);
      expect(cb.isClosed, isTrue);
      expect(cb.isOpen, isFalse);
      expect(cb.isHalfOpen, isFalse);
    });

    test('el contador de fallos inicia en cero', () {
      expect(cb.failureCount, 0);
    });

    test('secondsUntilRetry es 0 cuando está CLOSED', () {
      expect(cb.secondsUntilRetry, 0);
    });

    test('toString incluye el nombre y el estado', () {
      expect(cb.toString(), contains('weddy-api'));
      expect(cb.toString(), contains('closed'));
    });
  });

  group('CircuitBreaker — estado CLOSED', () {
    late CircuitBreaker cb;

    setUp(() {
      cb = CircuitBreaker(name: 'test', failureThreshold: 3);
    });

    test('execute() retorna el valor de la acción cuando está CLOSED', () async {
      final result = await cb.execute(() async => 42);
      expect(result, 42);
    });

    test('execute() retorna string correctamente', () async {
      final result = await cb.execute(() async => 'ok');
      expect(result, 'ok');
    });

    test('un fallo incrementa el contador pero no abre el circuito', () async {
      try {
        await cb.execute(() async => throw Exception('fallo'));
      } catch (_) {}
      expect(cb.failureCount, 1);
      expect(cb.isClosed, isTrue);
    });

    test('dos fallos consecutivos no abren el circuito (umbral = 3)', () async {
      for (int i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }
      expect(cb.failureCount, 2);
      expect(cb.isClosed, isTrue);
    });

    test('un éxito tras fallos parciales reinicia el contador', () async {
      try {
        await cb.execute(() async => throw Exception());
      } catch (_) {}
      expect(cb.failureCount, 1);

      await cb.execute(() async => 'recuperado');
      expect(cb.failureCount, 0);
      expect(cb.isClosed, isTrue);
    });

    test('execute() relanza la excepción original al fallar', () async {
      final excepcion = Exception('error original');
      expect(
        () => cb.execute(() async => throw excepcion),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CircuitBreaker — transición CLOSED → OPEN', () {
    late CircuitBreaker cb;

    setUp(() {
      cb = CircuitBreaker(name: 'test', failureThreshold: 3);
    });

    Future<void> fallar() async {
      try {
        await cb.execute(() async => throw Exception('fallo'));
      } catch (_) {}
    }

    test('al alcanzar failureThreshold el circuito se abre', () async {
      await fallar();
      await fallar();
      await fallar();
      expect(cb.isOpen, isTrue);
    });

    test('el contador de fallos llega a failureThreshold', () async {
      await fallar();
      await fallar();
      await fallar();
      expect(cb.failureCount, 3);
    });

    test('en estado OPEN lanza CircuitBreakerException', () async {
      await fallar();
      await fallar();
      await fallar();

      expect(
        () => cb.execute(() async => 'llamada bloqueada'),
        throwsA(isA<CircuitBreakerException>()),
      );
    });

    test('CircuitBreakerException no se cuenta como fallo adicional', () async {
      await fallar();
      await fallar();
      await fallar();
      final fallosAntes = cb.failureCount;

      try {
        await cb.execute(() async => 'bloqueado');
      } catch (_) {}

      expect(cb.failureCount, fallosAntes);
    });
  });

  group('CircuitBreaker — transición OPEN → HALF_OPEN → CLOSED/OPEN', () {
    test('después de resetTimeout el circuito pasa a HALF_OPEN y acepta la llamada', () async {
      final cb = CircuitBreaker(
        name: 'rapido',
        failureThreshold: 2,
        resetTimeout: const Duration(milliseconds: 10),
      );

      for (int i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }
      expect(cb.isOpen, isTrue);

      await Future.delayed(const Duration(milliseconds: 20));

      // La llamada de prueba tiene éxito → vuelve a CLOSED
      final result = await cb.execute(() async => 'recuperado');
      expect(result, 'recuperado');
      expect(cb.isClosed, isTrue);
      expect(cb.failureCount, 0);
    });

    test('si la llamada de prueba en HALF_OPEN falla, vuelve a OPEN', () async {
      final cb = CircuitBreaker(
        name: 'rapido2',
        failureThreshold: 2,
        resetTimeout: const Duration(milliseconds: 10),
      );

      for (int i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }

      await Future.delayed(const Duration(milliseconds: 20));

      try {
        await cb.execute(() async => throw Exception('fallo en half-open'));
      } catch (_) {}

      expect(cb.isOpen, isTrue);
    });
  });

  group('CircuitBreaker — reset() manual', () {
    test('reset() vuelve al estado CLOSED y limpia el contador', () async {
      final cb = CircuitBreaker(name: 'test', failureThreshold: 2);

      for (int i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }
      expect(cb.isOpen, isTrue);

      cb.reset();

      expect(cb.isClosed, isTrue);
      expect(cb.failureCount, 0);
    });

    test('después de reset() se puede volver a ejecutar acciones', () async {
      final cb = CircuitBreaker(name: 'test', failureThreshold: 2);

      for (int i = 0; i < 2; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }
      cb.reset();

      final result = await cb.execute(() async => 99);
      expect(result, 99);
    });
  });

  group('CircuitBreaker — failureThreshold personalizado', () {
    test('con umbral 1, el primer fallo abre el circuito', () async {
      final cb = CircuitBreaker(name: 'estricto', failureThreshold: 1);
      try {
        await cb.execute(() async => throw Exception());
      } catch (_) {}
      expect(cb.isOpen, isTrue);
    });

    test('con umbral 5, cuatro fallos no abren el circuito', () async {
      final cb = CircuitBreaker(name: 'tolerante', failureThreshold: 5);
      for (int i = 0; i < 4; i++) {
        try {
          await cb.execute(() async => throw Exception());
        } catch (_) {}
      }
      expect(cb.isClosed, isTrue);
      expect(cb.failureCount, 4);
    });
  });
}
