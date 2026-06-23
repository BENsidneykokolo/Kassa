# Notes projet Kassa

## Build
- **NE JAMAIS lancer `flutter clean`** — le build Gradle est trop long (~30 min+)
- Flutter SDK : `C:\Users\Utilisateur\Downloads\flutter\bin\flutter.bat`
- Pour builder : `flutter build apk --release` (ou `--debug` pour tester)
- APK de sortie : `yabisso_kassa\build\app\outputs\flutter-apk\`
- Toujours utiliser le script PowerShell existant (`flutter_build2.ps1`) plutôt que `flutter clean` + build
