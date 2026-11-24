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

La connexion est uniquement une démonstration locale : elle accepte tout
identifiant et mot de passe non vides et ne protège pas de vraies données.
