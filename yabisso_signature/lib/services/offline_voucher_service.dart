import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:yabisso_signature/models/signature.dart';
import 'package:yabisso_signature/database/database_helper.dart';

class OfflineVoucherService {
  static final OfflineVoucherService instance = OfflineVoucherService._init();
  OfflineVoucherService._init();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> saveSignatureImage(String signatureId, List<int> bytes) async {
    final path = await _localPath;
    final file = File('$path/signature_$signatureId.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deleteSignatureFile(String? path) async {
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<String> generatePdf(SignatureModel signature) async {
    final pdf = pw.Document();
    final path = await _localPath;
    final file = File('$path/signature_${signature.id}.pdf');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Document Signe', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Nom du document: ${signature.documentName}', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Signataire: ${signature.signerName}', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Email: ${signature.signerEmail}', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Type: ${signature.typeLabel}', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Statut: ${signature.statusLabel}', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Date: ${signature.createdAt.day}/${signature.createdAt.month}/${signature.createdAt.year}',
              style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 30),
          if (signature.signaturePath != null) ...[
            pw.Text('Signature:', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Image(
              pw.MemoryImage(File(signature.signaturePath!).readAsBytesSync()),
              width: 200,
              height: 100,
            ),
          ],
          if (signature.signatureType == SignatureType.texte) ...[
            pw.SizedBox(height: 20),
            pw.Text('Signature textuelle: ${signature.signerName}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
          pw.SizedBox(height: 50),
          pw.Divider(),
          pw.Text('Document genere par Yabisso Signature',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<void> shareSignature(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'Signature Yabisso');
  }

  Future<void> shareViaWhatsApp(String phone, String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'Voici la signature signee: ');
  }

  Future<void> saveOfflineSignature(SignatureModel signature) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertSignature(signature.toMap());
  }

  Future<List<SignatureModel>> getOfflineSignatures() async {
    final dbHelper = DatabaseHelper.instance;
    final maps = await dbHelper.getAllSignatures();
    return maps.map((map) => SignatureModel.fromMap(map)).toList();
  }
}
