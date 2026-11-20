import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cv_flutter_lucien/main.dart';

void main() {
  testWidgets('connexion et navigation entre les pages', (tester) async {
    await tester.pumpWidget(const CvApp());

    expect(find.text('Bienvenue !'), findsOneWidget);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Entre ton identifiant.'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'demo');
    await tester.enterText(find.byType(EditableText).last, 'motdepasse');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Votre prénom NOM'), findsOneWidget);

    await tester.tap(find.text('Famille'));
    await tester.pumpAndSettle();
    expect(find.text('Les personnes qui comptent pour moi.'), findsOneWidget);

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();
    expect(find.text('ton.email@exemple.com'), findsOneWidget);
  });
}
