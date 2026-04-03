import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bebidasdelivery/app/app.dart';

void main() {
  testWidgets('exibe o catalogo de bebidas', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Bebidas Disponiveis'), findsOneWidget);
    expect(find.text('Cerveja Artesanal IPA'), findsOneWidget);
    expect(find.text('Suco de Laranja Natural'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('mostra feedback ao tocar em uma bebida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('Cerveja Artesanal IPA'));
    await tester.pump();

    expect(find.text('Cerveja Artesanal IPA selecionado'), findsOneWidget);
  });
}
