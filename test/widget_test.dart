import 'package:flutter_test/flutter_test.dart';

import 'package:cv_flutter_lucien/main.dart';

void main() {
  testWidgets('affiche le formulaire d’authentification API', (tester) async {
    await tester.pumpWidget(const CvApp());

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Entre ton adresse e-mail.'), findsOneWidget);

    await tester.tap(find.text('Pas de compte ? Créer un compte'));
    await tester.pump();
    expect(find.text('Créer le compte'), findsOneWidget);
  });
}
