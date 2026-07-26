import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yabisso_signature/core/theme/app_theme.dart';
import 'package:yabisso_signature/models/signature.dart';
import 'package:yabisso_signature/providers/providers.dart';

class AddSignatureScreen extends ConsumerStatefulWidget {
  const AddSignatureScreen({super.key});

  @override
  ConsumerState<AddSignatureScreen> createState() => _AddSignatureScreenState();
}

class _AddSignatureScreenState extends ConsumerState<AddSignatureScreen> {
  final _documentNameController = TextEditingController();
  final _signerNameController = TextEditingController();
  final _signerEmailController = TextEditingController();
  final _textSignatureController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedType = 0; // 0=Dessin, 1=Texte, 2=Image
  Color _drawColor = Colors.black;
  double _strokeWidth = 3.0;
  final List<DrawnLine?> _lines = [];
  final List<DrawnLine?> _undoStack = [];
  String? _selectedFontFamily;
  Color _textSignatureColor = Colors.black;
  Uint8List? _imageBytes;
  bool _isSaving = false;

  final List<String> _fontOptions = [
    'Poppins',
    'Roboto',
    'Playfair Display',
    'Great Vibes',
    'Dancing Script',
    'Pacifico',
    'Lobster',
    'Satisfy',
  ];

  final List<Color> _colorOptions = [
    Colors.black,
    AppTheme.primaryColor,
    Colors.red,
    Colors.green,
    Colors.deepPurple,
  ];

  @override
  void dispose() {
    _documentNameController.dispose();
    _signerNameController.dispose();
    _signerEmailController.dispose();
    _textSignatureController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _lines.add(DrawnLine(
        [details.localPosition],
        _drawColor,
        _strokeWidth,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      final lastLine = _lines.last;
      final points = List<Offset>.from(lastLine.points)..add(details.localPosition);
      _lines[_lines.length - 1] = DrawnLine(points, _drawColor, _strokeWidth);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _undoStack.clear();
    });
  }

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _undoStack.add(_lines.removeLast());
      });
    }
  }

  void _redo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _lines.add(_undoStack.removeLast());
      });
    }
  }

  void _clear() {
    setState(() {
      _lines.clear();
      _undoStack.clear();
    });
  }

  Future<Uint8List?> _captureSignature() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 500, 200),
        const Radius.circular(8),
      ),
      backgroundPaint,
    );

    for (final line in _lines) {
      if (line == null || line.points.isEmpty) continue;
      paint.color = line.color;
      paint.strokeWidth = line.width;

      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(500, 200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<String> _saveSignatureImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/signature_${const Uuid().v4()}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Uint8List? _generateTextSignatureImage() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    canvas.drawColor(Colors.white, BlendMode.src);

    final text = _textSignatureController.text.isNotEmpty
        ? _textSignatureController.text
        : _signerNameController.text;

    if (text.isEmpty) return null;

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: _textSignatureColor,
        fontSize: 32,
        fontFamily: _selectedFontFamily,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 60));

    final picture = recorder.endRecording();
    final image = picture.toImageSync(400, 150);
    final byteData = image.toByteDataSync(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveSignature() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      Uint8List? signatureBytes;
      String? signaturePath;

      if (_selectedType == 0) {
        signatureBytes = await _captureSignature();
        if (signatureBytes != null) {
          signaturePath = await _saveSignatureImage(signatureBytes);
        }
      } else if (_selectedType == 1) {
        signatureBytes = _generateTextSignatureImage();
        if (signatureBytes != null) {
          signaturePath = await _saveSignatureImage(signatureBytes);
        }
      } else if (_selectedType == 2 && _imageBytes != null) {
        signatureBytes = _imageBytes;
        signaturePath = await _saveSignatureImage(_imageBytes!);
      }

      final signature = SignatureModel(
        id: const Uuid().v4(),
        documentName: _documentNameController.text,
        signerName: _signerNameController.text,
        signerEmail: _signerEmailController.text,
        signaturePath: signaturePath,
        signatureType: SignatureType.values[_selectedType],
        status: SignatureStatus.signe,
        createdAt: DateTime.now(),
        signatureBytes: signatureBytes,
        fontStyle: _selectedFontFamily,
        textColor: _textSignatureColor.value.toRadixString(16),
      );

      await ref.read(signaturesProvider.notifier).addSignature(signature);

      ref.read(pointsServiceProvider).addSignaturePoints();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signature créée avec succès!')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle signature'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveSignature,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du document',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _documentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du document *',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _signerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du signataire *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _signerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email du signataire *',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type de signature',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeOption(0, 'Dessin', Icons.draw),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTypeOption(1, 'Texte', Icons.text_fields),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTypeOption(2, 'Image', Icons.image),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedType == 0) _buildDrawingPad(),
              if (_selectedType == 1) _buildTextSignature(),
              if (_selectedType == 2) _buildImageUpload(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(int index, String label, IconData icon) {
    final isSelected = _selectedType == index;
    return InkWell(
      onTap: () => setState(() => _selectedType = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingPad() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dessinez votre signature',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: _undo,
                      tooltip: 'Annuler',
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed: _redo,
                      tooltip: 'Refaire',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _clear,
                      tooltip: 'Effacer tout',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: SignaturePainter(_lines),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Couleur: '),
                ..._colorOptions.map((color) => GestureDetector(
                  onTap: () => setState(() => _drawColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _drawColor == color ? AppTheme.primaryColor : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Epaisseur: '),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: _strokeWidth.round().toString(),
                    onChanged: (v) => setState(() => _strokeWidth = v),
                  ),
                ),
                Text('${_strokeWidth.round()}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSignature() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signature en texte',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textSignatureController,
              decoration: const InputDecoration(
                labelText: 'Texte de la signature',
                hintText: 'Entrez votre nom ou texte',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Police d\'ecriture:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fontOptions.map((font) {
                final isSelected = _selectedFontFamily == font;
                return ChoiceChip(
                  label: Text(font, style: TextStyle(fontFamily: font)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFontFamily = selected ? font : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Couleur du texte:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: _colorOptions.map((color) => GestureDetector(
                onTap: () => setState(() => _textSignatureColor = color),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _textSignatureColor == color ? AppTheme.primaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  _textSignatureController.text.isNotEmpty
                      ? _textSignatureController.text
                      : _signerNameController.text.isNotEmpty
                          ? _signerNameController.text
                          : 'Apercu',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: _selectedFontFamily,
                    color: _textSignatureColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signature par image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_imageBytes != null) ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _imageBytes = null),
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: AppTheme.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez pour ajouter une image',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // For demo, create a placeholder signature
                  final recorder = ui.PictureRecorder();
                  final canvas = Canvas(recorder);
                  canvas.drawColor(Colors.white, BlendMode.src);

                  final paint = Paint()
                    ..color = Colors.black
                    ..strokeWidth = 3
                    ..style = PaintingStyle.stroke
                    ..strokeCap = StrokeCap.round;

                  final path = Path()
                    ..moveTo(50, 80)
                    ..quadraticBezierTo(100, 20, 150, 80)
                    ..quadraticBezierTo(200, 140, 250, 60)
                    ..quadraticBezierTo(300, 0, 350, 80);

                  canvas.drawPath(path, paint);

                  final picture = recorder.endRecording();
                  final image = picture.toImageSync(400, 150);
                  final byteData = image.toByteDataSync(format: ui.ImageByteFormat.png);
                  setState(() => _imageBytes = byteData?.buffer.asUint8List());
                },
                icon: const Icon(Icons.image),
                label: const Text('Ajouter une image (demo)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine(this.points, this.color, this.width);
}

class SignaturePainter extends CustomPainter {
  final List<DrawnLine?> lines;

  SignaturePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final line in lines) {
      if (line == null || line.points.isEmpty) continue;
      paint.color = line.color;
      paint.strokeWidth = line.width;

      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
