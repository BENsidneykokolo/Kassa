import 'dart:ui';
import 'dart:io';

void main() async {
  const sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  final employesDir = Directory('C:/Users/Utilisateur/Documents/Ben/Kassa/yabisso_employes/android/app/src/main/res');
  final adminDir = Directory('C:/Users/Utilisateur/Documents/Ben/Kassa/yabisso_admin/android/app/src/main/res');

  for (final entry in sizes.entries) {
    final size = entry.value;
    final dirName = entry.key;

    // Generate E icon
    final eBytes = await renderEIcon(size);
    final eDir = Directory('${employesDir.path}/$dirName');
    if (!eDir.existsSync()) eDir.createSync(recursive: true);
    await File('${eDir.path}/ic_launcher.png').writeAsBytes(eBytes);
    await File('${eDir.path}/ic_launcher_round.png').writeAsBytes(eBytes);
    print('Employés $dirName ($size) OK');

    // Generate A icon
    final aBytes = await renderAIcon(size);
    final aDir = Directory('${adminDir.path}/$dirName');
    if (!aDir.existsSync()) aDir.createSync(recursive: true);
    await File('${aDir.path}/ic_launcher.png').writeAsBytes(aBytes);
    await File('${aDir.path}/ic_launcher_round.png').writeAsBytes(aBytes);
    print('Admin $dirName ($size) OK');
  }
}

Future<List<int>> renderEIcon(int size) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
  final s = size / 512.0;

  // Fond arrondi
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), Radius.circular(96 * s)),
    Paint()..color = const Color(0xFF15151f),
  );

  // Barre verticale bleue
  canvas.drawLine(Offset(176 * s, 120 * s), Offset(176 * s, 392 * s), Paint()..color = const Color(0xFF3E6BF6)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  // Bras supérieur rouge
  canvas.drawLine(Offset(176 * s, 140 * s), Offset(366 * s, 140 * s), Paint()..color = const Color(0xFFEA4335)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  // Bras médian vert
  canvas.drawLine(Offset(176 * s, 256 * s), Offset(336 * s, 256 * s), Paint()..color = const Color(0xFF34A853)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  // Bras inférieur jaune + point
  canvas.drawLine(Offset(176 * s, 372 * s), Offset(252 * s, 372 * s), Paint()..color = const Color(0xFFFBBC05)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  canvas.drawCircle(Offset(298 * s, 372 * s), 34 * s, Paint()..color = const Color(0xFFFBBC05));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}

Future<List<int>> renderAIcon(int size) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
  final s = size / 512.0;

  // Fond arrondi
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), Radius.circular(96 * s)),
    Paint()..color = const Color(0xFF15151f),
  );

  // Jambe gauche bleue
  canvas.drawLine(Offset(256 * s, 120 * s), Offset(156 * s, 392 * s), Paint()..color = const Color(0xFF3E6BF6)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  // Jambe droite rouge
  canvas.drawLine(Offset(256 * s, 120 * s), Offset(330 * s, 344 * s), Paint()..color = const Color(0xFFEA4335)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);
  // Point jaune
  canvas.drawCircle(Offset(348 * s, 368 * s), 34 * s, Paint()..color = const Color(0xFFFBBC05));
  // Barre transversale verte
  canvas.drawLine(Offset(197 * s, 280 * s), Offset(315 * s, 280 * s), Paint()..color = const Color(0xFF34A853)..strokeWidth = 46 * s..strokeCap = StrokeCap.round);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}
