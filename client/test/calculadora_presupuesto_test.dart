// Proyecto: Weddy - Wedding Planner
// Entrega 3 - Diseño y Arquitectura de Software
// Pruebas unitarias: CalculadoraPresupuesto

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planer_1/utils/calculadora_presupuesto.dart';
import 'package:wedding_planer_1/models/invitado.dart';
import 'package:wedding_planer_1/enums/estado_invitado.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_dj.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_catering.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_fotografia.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Invitado _invitado(EstadoInvitado estado) => Invitado(
      id: estado.name,
      nombre: 'Test',
      apellido: 'Weddy',
      correo: 'test@weddy.com',
      estado: estado,
    );

ProveedorDj _dj({double costoBase = 1000.0, int horas = 4}) => ProveedorDj(
      id: 'dj-1',
      nombre: 'DJ Test',
      contacto: 'dj@test.com',
      costoBase: costoBase,
      horasDeServicio: horas,
    );

ProveedorCatering _catering({
  double costoBase = 500.0,
  int platillos = 10,
  double costoPorPlatillo = 25.0,
}) =>
    ProveedorCatering(
      id: 'cat-1',
      nombre: 'Catering Test',
      contacto: 'cat@test.com',
      costoBase: costoBase,
      numeroDePlatillos: platillos,
      costoPorPlatillo: costoPorPlatillo,
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── contarConfirmados ─────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.contarConfirmados', () {
    test('lista vacía → 0', () {
      expect(CalculadoraPresupuesto.contarConfirmados([]), 0);
    });

    test('todos pendientes → 0', () {
      final invitados = [
        _invitado(EstadoInvitado.pendiente),
        _invitado(EstadoInvitado.pendiente),
      ];
      expect(CalculadoraPresupuesto.contarConfirmados(invitados), 0);
    });

    test('todos confirmados → cuenta todos', () {
      final invitados = [
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.confirmado),
      ];
      expect(CalculadoraPresupuesto.contarConfirmados(invitados), 3);
    });

    test('mezcla de estados → solo cuenta confirmados', () {
      final invitados = [
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.pendiente),
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.rechazado),
      ];
      expect(CalculadoraPresupuesto.contarConfirmados(invitados), 2);
    });

    test('rechazados no se cuentan', () {
      final invitados = [
        _invitado(EstadoInvitado.rechazado),
        _invitado(EstadoInvitado.rechazado),
      ];
      expect(CalculadoraPresupuesto.contarConfirmados(invitados), 0);
    });
  });

  // ── costoInvitados ────────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.costoInvitados', () {
    test('sin confirmados → 0.0', () {
      final invitados = [_invitado(EstadoInvitado.pendiente)];
      expect(
        CalculadoraPresupuesto.costoInvitados(
          invitados: invitados, costoPorPersona: 50.0,
        ),
        0.0,
      );
    });

    test('1 confirmado × 75 → 75.0', () {
      final invitados = [_invitado(EstadoInvitado.confirmado)];
      expect(
        CalculadoraPresupuesto.costoInvitados(
          invitados: invitados, costoPorPersona: 75.0,
        ),
        75.0,
      );
    });

    test('3 confirmados × 100 → 300.0', () {
      final invitados = List.generate(
        3, (_) => _invitado(EstadoInvitado.confirmado),
      );
      expect(
        CalculadoraPresupuesto.costoInvitados(
          invitados: invitados, costoPorPersona: 100.0,
        ),
        300.0,
      );
    });

    test('ignora pendientes en el cálculo', () {
      final invitados = [
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.pendiente),
        _invitado(EstadoInvitado.confirmado),
      ];
      expect(
        CalculadoraPresupuesto.costoInvitados(
          invitados: invitados, costoPorPersona: 50.0,
        ),
        100.0,
      );
    });
  });

  // ── costoProveedores ──────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.costoProveedores', () {
    test('lista vacía → 0.0', () {
      expect(CalculadoraPresupuesto.costoProveedores([]), 0.0);
    });

    test('un proveedor → su calcularCostoFinal()', () {
      final dj = _dj(costoBase: 1000.0, horas: 4);
      expect(CalculadoraPresupuesto.costoProveedores([dj]), 1000.0);
    });

    test('suma correcta de múltiples proveedores', () {
      final dj = _dj(costoBase: 1000.0, horas: 4);         // 1000
      final catering = _catering(costoBase: 500.0, platillos: 10); // 500 + 250 = 750
      // total = 1750
      expect(CalculadoraPresupuesto.costoProveedores([dj, catering]), 1750.0);
    });

    test('incluye costos extras del DJ (horas adicionales)', () {
      final dj = _dj(costoBase: 800.0, horas: 6); // 800 + (2*50) = 900
      expect(CalculadoraPresupuesto.costoProveedores([dj]), 900.0);
    });
  });

  // ── desglosePorProveedor ──────────────────────────────────────────────────
  group('CalculadoraPresupuesto.desglosePorProveedor', () {
    test('lista vacía → mapa vacío', () {
      expect(CalculadoraPresupuesto.desglosePorProveedor([]), isEmpty);
    });

    test('retorna un mapa nombre → costoFinal', () {
      final dj = _dj(costoBase: 1000.0, horas: 4);
      final desglose = CalculadoraPresupuesto.desglosePorProveedor([dj]);
      expect(desglose['DJ Test'], 1000.0);
    });

    test('mapa contiene una entrada por proveedor', () {
      final dj = _dj();
      final catering = _catering();
      final desglose = CalculadoraPresupuesto.desglosePorProveedor([dj, catering]);
      expect(desglose.length, 2);
      expect(desglose.containsKey('DJ Test'), isTrue);
      expect(desglose.containsKey('Catering Test'), isTrue);
    });
  });

  // ── costoTotal ────────────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.costoTotal', () {
    test('sin invitados confirmados ni proveedores → 0.0', () {
      expect(
        CalculadoraPresupuesto.costoTotal(
          invitados: [_invitado(EstadoInvitado.pendiente)],
          proveedores: [],
          costoPorPersona: 50.0,
        ),
        0.0,
      );
    });

    test('costoTotal = costoInvitados + costoProveedores', () {
      final invitados = [
        _invitado(EstadoInvitado.confirmado),
        _invitado(EstadoInvitado.confirmado),
      ]; // 2 × 100 = 200
      final proveedores = [_dj(costoBase: 800.0, horas: 4)]; // 800

      expect(
        CalculadoraPresupuesto.costoTotal(
          invitados: invitados,
          proveedores: proveedores,
          costoPorPersona: 100.0,
        ),
        1000.0,
      );
    });

    test('con fotografía con video el total incluye el recargo', () {
      final foto = ProveedorFotografia(
        id: 'f1', nombre: 'Foto Art', contacto: 'x',
        costoBase: 1000.0, horasCobertura: 0, incluyeVideo: true,
      );
      // recargo = 200, horas = 0 → total foto = 1200
      expect(
        CalculadoraPresupuesto.costoTotal(
          invitados: [],
          proveedores: [foto],
          costoPorPersona: 0.0,
        ),
        1200.0,
      );
    });
  });

  // ── saldoRestante ─────────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.saldoRestante', () {
    test('sin gasto → saldo = presupuesto máximo', () {
      expect(
        CalculadoraPresupuesto.saldoRestante(
          presupuestoMaximo: 5000.0, costoActual: 0.0,
        ),
        5000.0,
      );
    });

    test('saldo = presupuesto - costo', () {
      expect(
        CalculadoraPresupuesto.saldoRestante(
          presupuestoMaximo: 10000.0, costoActual: 3000.0,
        ),
        7000.0,
      );
    });

    test('saldo negativo cuando el costo supera el máximo', () {
      expect(
        CalculadoraPresupuesto.saldoRestante(
          presupuestoMaximo: 1000.0, costoActual: 1500.0,
        ),
        -500.0,
      );
    });
  });

  // ── porcentajeUtilizado ───────────────────────────────────────────────────
  group('CalculadoraPresupuesto.porcentajeUtilizado', () {
    test('0 de gasto → 0%', () {
      expect(
        CalculadoraPresupuesto.porcentajeUtilizado(
          presupuestoMaximo: 10000.0, costoActual: 0.0,
        ),
        0.0,
      );
    });

    test('gasto = máximo → 100%', () {
      expect(
        CalculadoraPresupuesto.porcentajeUtilizado(
          presupuestoMaximo: 5000.0, costoActual: 5000.0,
        ),
        100.0,
      );
    });

    test('gasto = mitad → 50%', () {
      expect(
        CalculadoraPresupuesto.porcentajeUtilizado(
          presupuestoMaximo: 10000.0, costoActual: 5000.0,
        ),
        50.0,
      );
    });

    test('presupuestoMaximo = 0 → retorna 0.0 (evita división por cero)', () {
      expect(
        CalculadoraPresupuesto.porcentajeUtilizado(
          presupuestoMaximo: 0.0, costoActual: 500.0,
        ),
        0.0,
      );
    });

    test('presupuestoMaximo negativo → retorna 0.0', () {
      expect(
        CalculadoraPresupuesto.porcentajeUtilizado(
          presupuestoMaximo: -100.0, costoActual: 50.0,
        ),
        0.0,
      );
    });
  });

  // ── estaExcedido ──────────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.estaExcedido', () {
    test('costo < máximo → no excedido', () {
      expect(
        CalculadoraPresupuesto.estaExcedido(
          presupuestoMaximo: 10000.0, costoActual: 8000.0,
        ),
        isFalse,
      );
    });

    test('costo == máximo → no excedido (límite exacto)', () {
      expect(
        CalculadoraPresupuesto.estaExcedido(
          presupuestoMaximo: 5000.0, costoActual: 5000.0,
        ),
        isFalse,
      );
    });

    test('costo > máximo → excedido', () {
      expect(
        CalculadoraPresupuesto.estaExcedido(
          presupuestoMaximo: 5000.0, costoActual: 5001.0,
        ),
        isTrue,
      );
    });

    test('costo = 0 nunca está excedido', () {
      expect(
        CalculadoraPresupuesto.estaExcedido(
          presupuestoMaximo: 100.0, costoActual: 0.0,
        ),
        isFalse,
      );
    });
  });

  // ── cercaDelLimite ────────────────────────────────────────────────────────
  group('CalculadoraPresupuesto.cercaDelLimite', () {
    test('al 79% no está cerca del límite (umbral default = 80%)', () {
      expect(
        CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 10000.0, costoActual: 7900.0,
        ),
        isFalse,
      );
    });

    test('al 80% exacto está cerca del límite', () {
      expect(
        CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 10000.0, costoActual: 8000.0,
        ),
        isTrue,
      );
    });

    test('al 95% está cerca del límite', () {
      expect(
        CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 10000.0, costoActual: 9500.0,
        ),
        isTrue,
      );
    });

    test('umbral personalizado al 50%', () {
      expect(
        CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 10000.0, costoActual: 5000.0, umbral: 50.0,
        ),
        isTrue,
      );
      expect(
        CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 10000.0, costoActual: 4999.0, umbral: 50.0,
        ),
        isFalse,
      );
    });

    test('presupuesto = 0 no lanza excepción', () {
      expect(
        () => CalculadoraPresupuesto.cercaDelLimite(
          presupuestoMaximo: 0.0, costoActual: 100.0,
        ),
        returnsNormally,
      );
    });
  });
}
