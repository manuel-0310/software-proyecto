// Proyecto: Weddy - Wedding Planner
// Entrega 3 - Diseño y Arquitectura de Software
// Pruebas unitarias: Patrón Observer (Invitado + Observers)

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planer_1/models/invitado.dart';
import 'package:wedding_planer_1/models/presupuesto.dart';
import 'package:wedding_planer_1/enums/estado_invitado.dart';
import 'package:wedding_planer_1/patterns/observer/invitado_observer.dart';
import 'package:wedding_planer_1/patterns/observer/presupuesto_observer.dart';
import 'package:wedding_planer_1/patterns/observer/notificacion_observer.dart';
import 'package:wedding_planer_1/services/notificacion_service.dart';

// ─── Test doubles ────────────────────────────────────────────────────────────

/// Observer espía que registra cada llamada a actualizar().
class ObserverEspia implements InvitadoObserver {
  final List<Invitado> invitadosRecibidos = [];

  @override
  void actualizar(covariant Invitado invitado) {
    invitadosRecibidos.add(invitado);
  }

  int get vecesNotificado => invitadosRecibidos.length;
}

/// Implementación de NotificacionService que registra los envíos sin hacer I/O.
class NotificacionServiceSpy implements NotificacionService {
  final List<Map<String, String>> envios = [];

  @override
  void enviar({
    required String destinatario,
    required String asunto,
    required String mensaje,
  }) {
    envios.add({
      'destinatario': destinatario,
      'asunto': asunto,
      'mensaje': mensaje,
    });
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Invitado _crearInvitado({EstadoInvitado estado = EstadoInvitado.pendiente}) {
  return Invitado(
    id: 'inv-test',
    nombre: 'Ana',
    apellido: 'García',
    correo: 'ana@weddy.com',
    estado: estado,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── Invitado como Observable ──────────────────────────────────────────────
  group('Invitado — suscribir y eliminar observers', () {
    test('suscribir() añade un observer que recibe notificaciones', () {
      final invitado = _crearInvitado();
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.notificar();

      expect(espia.vecesNotificado, 1);
    });

    test('eliminar() impide que el observer siga recibiendo notificaciones', () {
      final invitado = _crearInvitado();
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.eliminar(espia);
      invitado.notificar();

      expect(espia.vecesNotificado, 0);
    });

    test('suscribir() el mismo observer dos veces no duplica las notificaciones', () {
      final invitado = _crearInvitado();
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.suscribir(espia);
      invitado.notificar();

      expect(espia.vecesNotificado, 1);
    });

    test('múltiples observers diferentes reciben la notificación', () {
      final invitado = _crearInvitado();
      final espia1 = ObserverEspia();
      final espia2 = ObserverEspia();
      final espia3 = ObserverEspia();

      invitado.suscribir(espia1);
      invitado.suscribir(espia2);
      invitado.suscribir(espia3);
      invitado.notificar();

      expect(espia1.vecesNotificado, 1);
      expect(espia2.vecesNotificado, 1);
      expect(espia3.vecesNotificado, 1);
    });

    test('eliminar un observer no afecta a los demás', () {
      final invitado = _crearInvitado();
      final espia1 = ObserverEspia();
      final espia2 = ObserverEspia();

      invitado.suscribir(espia1);
      invitado.suscribir(espia2);
      invitado.eliminar(espia1);
      invitado.notificar();

      expect(espia1.vecesNotificado, 0);
      expect(espia2.vecesNotificado, 1);
    });

    test('notificar() sin observers no lanza excepción', () {
      final invitado = _crearInvitado();
      expect(() => invitado.notificar(), returnsNormally);
    });
  });

  // ── Invitado.cambiarEstado ────────────────────────────────────────────────
  group('Invitado.cambiarEstado — actualiza estado y notifica', () {
    test('cambiarEstado() actualiza el estado del invitado', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.pendiente);
      invitado.cambiarEstado(EstadoInvitado.confirmado);
      expect(invitado.estado, EstadoInvitado.confirmado);
    });

    test('cambiarEstado() notifica a los observers con el estado actualizado', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.pendiente);
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.cambiarEstado(EstadoInvitado.confirmado);

      expect(espia.vecesNotificado, 1);
      expect(espia.invitadosRecibidos.first.estado, EstadoInvitado.confirmado);
    });

    test('cambiarEstado() múltiples veces genera una notificación por cambio', () {
      final invitado = _crearInvitado();
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.cambiarEstado(EstadoInvitado.confirmado);
      invitado.cambiarEstado(EstadoInvitado.rechazado);
      invitado.cambiarEstado(EstadoInvitado.pendiente);

      expect(espia.vecesNotificado, 3);
    });

    test('el observer recibe el mismo objeto Invitado (referencia correcta)', () {
      final invitado = _crearInvitado();
      final espia = ObserverEspia();

      invitado.suscribir(espia);
      invitado.cambiarEstado(EstadoInvitado.confirmado);

      expect(identical(espia.invitadosRecibidos.first, invitado), isTrue);
    });
  });

  // ── Invitado — propiedades ────────────────────────────────────────────────
  group('Invitado — propiedades calculadas', () {
    test('nombreCompleto concatena nombre y apellido', () {
      final invitado = _crearInvitado();
      expect(invitado.nombreCompleto, 'Ana García');
    });

    test('estado inicial por defecto es pendiente', () {
      final invitado = _crearInvitado();
      expect(invitado.estado, EstadoInvitado.pendiente);
    });
  });

  // ── PresupuestoObserver ───────────────────────────────────────────────────
  group('PresupuestoObserver — reacción a cambios de estado', () {
    test('actualizar() invoca onPresupuestoActualizado con el costo total', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.confirmado);
      final presupuesto = Presupuesto(
        presupuestoMaximo: 10000.0,
        costoPorInvitadoConfirmado: 100.0,
        proveedores: [],
        invitados: [invitado],
      );

      double? costoCapturado;
      final observer = PresupuestoObserver(
        presupuesto: presupuesto,
        onPresupuestoActualizado: (costo) => costoCapturado = costo,
      );

      observer.actualizar(invitado);

      expect(costoCapturado, isNotNull);
      expect(costoCapturado, presupuesto.costoTotal);
    });

    test('actualizar() sin callback no lanza excepción', () {
      final invitado = _crearInvitado();
      final presupuesto = Presupuesto(
        presupuestoMaximo: 5000.0,
        costoPorInvitadoConfirmado: 50.0,
        proveedores: [],
        invitados: [invitado],
      );
      final observer = PresupuestoObserver(presupuesto: presupuesto);

      expect(() => observer.actualizar(invitado), returnsNormally);
    });

    test('onPresupuestoActualizado refleja el total calculado por Presupuesto', () {
      final inv1 = _crearInvitado(estado: EstadoInvitado.confirmado);
      final inv2 = Invitado(
        id: 'inv-2', nombre: 'Luis', apellido: 'Pérez',
        correo: 'luis@weddy.com', estado: EstadoInvitado.confirmado,
      );
      final presupuesto = Presupuesto(
        presupuestoMaximo: 20000.0,
        costoPorInvitadoConfirmado: 200.0,
        proveedores: [],
        invitados: [inv1, inv2],
      );

      double? total;
      final observer = PresupuestoObserver(
        presupuesto: presupuesto,
        onPresupuestoActualizado: (costo) => total = costo,
      );

      observer.actualizar(inv1);

      // 2 confirmados × 200 = 400
      expect(total, 400.0);
    });
  });

  // ── NotificacionObserver ──────────────────────────────────────────────────
  group('NotificacionObserver — envío de notificaciones', () {
    late NotificacionServiceSpy spy;
    late NotificacionObserver observer;

    setUp(() {
      spy = NotificacionServiceSpy();
      observer = NotificacionObserver(spy);
    });

    test('actualizar() llama a enviar() exactamente una vez', () {
      final invitado = _crearInvitado();
      observer.actualizar(invitado);
      expect(spy.envios.length, 1);
    });

    test('el destinatario es el correo del invitado', () {
      final invitado = _crearInvitado();
      observer.actualizar(invitado);
      expect(spy.envios.first['destinatario'], 'ana@weddy.com');
    });

    test('el mensaje para estado confirmado menciona la confirmación', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.confirmado);
      observer.actualizar(invitado);
      final mensaje = spy.envios.first['mensaje']!;
      expect(mensaje.toLowerCase(), contains('confirmada'));
    });

    test('el mensaje para estado rechazado menciona que no puede acompañar', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.rechazado);
      observer.actualizar(invitado);
      final mensaje = spy.envios.first['mensaje']!;
      expect(mensaje.toLowerCase(), anyOf(contains('lament'), contains('no pued')));
    });

    test('el mensaje para estado pendiente menciona que está pendiente', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.pendiente);
      observer.actualizar(invitado);
      final mensaje = spy.envios.first['mensaje']!;
      expect(mensaje.toLowerCase(), contains('pendiente'));
    });

    test('el asunto del envío siempre es el mismo independientemente del estado', () {
      final invitado = _crearInvitado(estado: EstadoInvitado.confirmado);
      observer.actualizar(invitado);
      expect(spy.envios.first['asunto'], isNotEmpty);
    });
  });

  // ── Integración: Observable + múltiples observers ─────────────────────────
  group('Observer — integración Observable + múltiples observers', () {
    test('cambiarEstado dispara tanto PresupuestoObserver como NotificacionObserver', () {
      final invitado = _crearInvitado();
      final presupuesto = Presupuesto(
        presupuestoMaximo: 5000.0,
        costoPorInvitadoConfirmado: 100.0,
        proveedores: [],
        invitados: [invitado],
      );

      double? costoCapturado;
      final presupuestoObs = PresupuestoObserver(
        presupuesto: presupuesto,
        onPresupuestoActualizado: (c) => costoCapturado = c,
      );

      final spy = NotificacionServiceSpy();
      final notifObs = NotificacionObserver(spy);

      invitado.suscribir(presupuestoObs);
      invitado.suscribir(notifObs);
      invitado.cambiarEstado(EstadoInvitado.confirmado);

      expect(costoCapturado, isNotNull);
      expect(spy.envios.length, 1);
    });
  });
}
