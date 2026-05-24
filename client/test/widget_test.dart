// Proyecto: Weddy - Wedding Planner
// Entrega 3 - Diseño y Arquitectura de Software
// Smoke test: verifica que la app Weddy arranca sin errores

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planer_1/main.dart';

void main() {
  testWidgets('Weddy app arranca sin lanzar excepciones', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Permite que el primer frame y las animaciones iniciales completen.
    await tester.pump();

    // La app muestra un MaterialApp (no crashea al inicializar).
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('La pantalla de inicio contiene el título WEDDY', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // El título de la app está presente en el widget tree.
    expect(find.text('WEDDY'), findsWidgets);
  });
}
