# CV Flutter

Petite application Flutter de démonstration avec une page de connexion, un CV,
une page famille et une page de contact.

## Démonstration vidéo

[Regarder la vidéo de présentation](media/demo-cv-flutter.mp4)

## Lancer l'application

Dans un terminal ouvert dans ce dossier :

```powershell
flutter pub get
flutter run -d chrome
```

Pour lancer la version Android, démarre un émulateur dans Android Studio, puis
exécute `flutter run`.

## Personnaliser

Les contenus de démonstration se trouvent dans `lib/main.dart`. Remplace le
nom, la formation, les expériences, les compétences, les membres de la famille
et les coordonnées par les tiens. Les cercles avec une icône d'appareil photo
sont des emplacements : ajoute tes photos avant de rendre le CV.

## API REST

L’application utilise l’API [`espoirbaraka/api-test`](https://github.com/espoirbaraka/api-test).

1. Installe XAMPP et démarre Apache ainsi que MySQL.
2. Place le dépôt API dans `C:\xampp\htdocs\api-test`.
3. Crée une base de données nommée `api` et importe `api.sql`.
4. Vérifie que cette adresse répond : `http://127.0.0.1/api-test/public/famille-membres`.

L’application utilise automatiquement :

- `http://127.0.0.1/api-test/public` sur Chrome ;
- `http://10.0.2.2/api-test/public` sur l’émulateur Android ;
- une URL personnalisée avec `--dart-define=API_BASE_URL=http://adresse/api-test/public`.

Cette URL peut être remplacée avec :

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1/api-test/public
```
