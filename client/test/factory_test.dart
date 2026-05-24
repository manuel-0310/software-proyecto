// Proyecto: Weddy - Wedding Planner
// Entrega 3 - Diseño y Arquitectura de Software
// Pruebas unitarias: Patrón Factory Method (Proveedores)

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planer_1/enums/tipo_proveedor.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_factory.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_dj.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_catering.dart';
import 'package:wedding_planer_1/patterns/factory/proveedor_fotografia.dart';

void main() {
  // ─── ProveedorFactory.segunTipo ──────────────────────────────────────────────
  group('ProveedorFactory.segunTipo — selección de fábrica correcta', () {
    test('segunTipo(dj) retorna una instancia de DjFactory', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.dj);
      expect(factory, isA<DjFactory>());
    });

    test('segunTipo(catering) retorna una instancia de CateringFactory', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.catering);
      expect(factory, isA<CateringFactory>());
    });

    test('segunTipo(fotografia) retorna una instancia de FotografiaFactory', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.fotografia);
      expect(factory, isA<FotografiaFactory>());
    });
  });

  // ─── DjFactory / ProveedorDj ─────────────────────────────────────────────────
  group('DjFactory — creación y cálculo de costo', () {
    late DjFactory factory;

    setUp(() => factory = DjFactory());

    test('crearProveedor() retorna una instancia de ProveedorDj', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ Elektra', contacto: 'dj@weddy.com', costoBase: 800.0,
      );
      expect(dj, isA<ProveedorDj>());
    });

    test('el tipo del proveedor creado es TipoProveedor.dj', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ Elektra', contacto: 'dj@weddy.com', costoBase: 800.0,
      );
      expect(dj.tipo, TipoProveedor.dj);
    });

    test('los atributos básicos se asignan correctamente', () {
      final dj = factory.crearProveedor(
        id: 'dj-01', nombre: 'DJ Bass', contacto: 'bass@test.com', costoBase: 600.0,
      );
      expect(dj.id, 'dj-01');
      expect(dj.nombre, 'DJ Bass');
      expect(dj.contacto, 'bass@test.com');
      expect(dj.costoBase, 600.0);
    });

    test('calcularCostoFinal() = costoBase cuando horasDeServicio == 4 (sin extras)', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ', contacto: 'x', costoBase: 1000.0,
        horasDeServicio: 4,
      );
      expect(dj.calcularCostoFinal(), 1000.0);
    });

    test('calcularCostoFinal() = costoBase cuando horasDeServicio < 4', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ', contacto: 'x', costoBase: 1000.0,
        horasDeServicio: 2,
      );
      // Horas extra = max(0, 2-4) = 0 → sin cargo adicional
      expect(dj.calcularCostoFinal(), 1000.0);
    });

    test('calcularCostoFinal() cobra 50 por cada hora extra sobre 4', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ', contacto: 'x', costoBase: 1000.0,
        horasDeServicio: 6,
      );
      // 6 - 4 = 2 horas extra × 50 = 100
      expect(dj.calcularCostoFinal(), 1100.0);
    });

    test('calcularCostoFinal() con 8 horas → 4 extras → +200', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ', contacto: 'x', costoBase: 500.0,
        horasDeServicio: 8,
      );
      expect(dj.calcularCostoFinal(), 700.0);
    });

    test('descripcionServicio() menciona las horas de servicio', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ', contacto: 'x', costoBase: 500.0,
        horasDeServicio: 5,
      );
      expect(dj.descripcionServicio(), contains('5'));
    });

    test('toString() incluye el tipo y el nombre', () {
      final dj = factory.crearProveedor(
        id: '1', nombre: 'DJ Elektra', contacto: 'x', costoBase: 800.0,
      );
      expect(dj.toString(), contains('DJ'));
      expect(dj.toString(), contains('DJ Elektra'));
    });
  });

  // ─── CateringFactory / ProveedorCatering ────────────────────────────────────
  group('CateringFactory — creación y cálculo de costo', () {
    late CateringFactory factory;

    setUp(() => factory = CateringFactory());

    test('crearProveedor() retorna una instancia de ProveedorCatering', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'Sabores Únicos', contacto: 'cat@weddy.com',
        costoBase: 2000.0, numeroDePlatillos: 100,
      );
      expect(catering, isA<ProveedorCatering>());
    });

    test('el tipo del proveedor es TipoProveedor.catering', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'Catering', contacto: 'x',
        costoBase: 1000.0, numeroDePlatillos: 50,
      );
      expect(catering.tipo, TipoProveedor.catering);
    });

    test('calcularCostoFinal() = costoBase + (platillos * 25) con costoPorPlatillo default', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'C', contacto: 'x',
        costoBase: 1000.0, numeroDePlatillos: 100,
      );
      // 1000 + (100 * 25) = 3500
      expect(catering.calcularCostoFinal(), 3500.0);
    });

    test('calcularCostoFinal() respeta costoPorPlatillo personalizado', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'C', contacto: 'x',
        costoBase: 500.0, numeroDePlatillos: 40,
        costoPorPlatillo: 30.0,
      );
      // 500 + (40 * 30) = 1700
      expect(catering.calcularCostoFinal(), 1700.0);
    });

    test('calcularCostoFinal() con 0 platillos = costoBase', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'C', contacto: 'x',
        costoBase: 800.0, numeroDePlatillos: 0,
      );
      expect(catering.calcularCostoFinal(), 800.0);
    });

    test('descripcionServicio() menciona el número de comensales', () {
      final catering = factory.crearProveedor(
        id: '2', nombre: 'C', contacto: 'x',
        costoBase: 500.0, numeroDePlatillos: 75,
      );
      expect(catering.descripcionServicio(), contains('75'));
    });
  });

  // ─── FotografiaFactory / ProveedorFotografia ─────────────────────────────────
  group('FotografiaFactory — creación y cálculo de costo', () {
    late FotografiaFactory factory;

    setUp(() => factory = FotografiaFactory());

    test('crearProveedor() retorna una instancia de ProveedorFotografia', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'Lente Dorado', contacto: 'foto@weddy.com',
        costoBase: 1500.0, horasCobertura: 6,
      );
      expect(foto, isA<ProveedorFotografia>());
    });

    test('el tipo del proveedor es TipoProveedor.fotografia', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x', costoBase: 1000.0, horasCobertura: 4,
      );
      expect(foto.tipo, TipoProveedor.fotografia);
    });

    test('calcularCostoFinal() sin video = costoBase + (horas * 40)', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x',
        costoBase: 1000.0, horasCobertura: 5, incluyeVideo: false,
      );
      // 1000 + (5 * 40) = 1200
      expect(foto.calcularCostoFinal(), 1200.0);
    });

    test('calcularCostoFinal() con video aplica recargo del 20% sobre costoBase', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x',
        costoBase: 1000.0, horasCobertura: 6, incluyeVideo: true,
      );
      // recargo = 1000 * 0.20 = 200
      // horas = 6 * 40 = 240
      // total = 1000 + 200 + 240 = 1440
      expect(foto.calcularCostoFinal(), 1440.0);
    });

    test('incluyeVideo default es false', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x', costoBase: 1000.0, horasCobertura: 4,
      );
      expect(foto.incluyeVideo, isFalse);
    });

    test('descripcionServicio() indica "Video" cuando incluyeVideo es true', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x',
        costoBase: 1000.0, horasCobertura: 4, incluyeVideo: true,
      );
      expect(foto.descripcionServicio(), contains('Video'));
    });

    test('descripcionServicio() indica solo fotografía cuando incluyeVideo es false', () {
      final foto = factory.crearProveedor(
        id: '3', nombre: 'F', contacto: 'x',
        costoBase: 1000.0, horasCobertura: 4, incluyeVideo: false,
      );
      expect(foto.descripcionServicio(), isNot(contains('Video')));
    });
  });

  // ─── Integración: segunTipo + crearProveedor ─────────────────────────────────
  group('Factory — integración con segunTipo', () {
    test('flujo completo: segunTipo(dj) → crearProveedor → calcularCostoFinal', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.dj);
      final dj = factory.crearProveedor(
        id: 'x', nombre: 'DJ Pro', contacto: 'x', costoBase: 1000.0,
      ) as ProveedorDj;
      expect(dj.calcularCostoFinal(), 1000.0);
      expect(dj.tipo, TipoProveedor.dj);
    });

    test('flujo completo: segunTipo(catering) → crearProveedor → tipo correcto', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.catering);
      final catering = factory.crearProveedor(
        id: 'x', nombre: 'La Mesa', contacto: 'x', costoBase: 500.0,
      );
      expect(catering.tipo, TipoProveedor.catering);
    });

    test('flujo completo: segunTipo(fotografia) → crearProveedor → tipo correcto', () {
      final factory = ProveedorFactory.segunTipo(TipoProveedor.fotografia);
      final foto = factory.crearProveedor(
        id: 'x', nombre: 'Foto Arte', contacto: 'x', costoBase: 800.0,
      );
      expect(foto.tipo, TipoProveedor.fotografia);
    });
  });
}
