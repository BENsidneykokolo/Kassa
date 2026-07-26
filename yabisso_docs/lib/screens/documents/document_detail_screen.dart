import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/document.dart';
import '../../services/currency_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final int documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  Document? _document;
  bool _loading = true;
  bool _editing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _clientController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _clientController = TextEditingController();
    _amountController = TextEditingController();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final doc = await DatabaseHelper.instance.getDocumentById(widget.documentId);
    if (doc != null) {
      _titleController.text = doc.title;
      _contentController.text = doc.content ?? '';
      _clientController.text = doc.clientName ?? '';
      _amountController.text = doc.amount?.toString() ?? '';
      setState(() { _document = doc; _loading = false; });
    }
  }

  Future<void> _saveChanges() async {
    if (_document == null) return;
    final updated = Document(
      id: _document!.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      templateId: _document!.templateId,
      type: _document!.type,
      status: _document!.status,
      clientName: _clientController.text.trim().isEmpty ? null : _clientController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()),
      createdAt: _document!.createdAt,
    );
    await DatabaseHelper.instance.updateDocument(updated);
    setState(() { _document = updated; _editing = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document mis à jour !'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteDocument() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce document ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await DatabaseHelper.instance.deleteDocument(widget.documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document supprimé'), backgroundColor: Colors.green),
      );
      context.go('/documents');
    }
  }

  Future<void> _generatePdf() async {
    if (_document == null) return;
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(child: pw.Text(_document!.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Text('Type: ${_document!.typeLabel}', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(width: 20),
            pw.Text('Statut: ${_document!.statusLabel}', style: const pw.TextStyle(fontSize: 12)),
          ]),
          if (_document!.clientName != null) ...[
            pw.SizedBox(height: 10),
            pw.Text('Client: ${_document!.clientName}', style: const pw.TextStyle(fontSize: 12)),
          ],
          if (_document!.amount != null) ...[
            pw.SizedBox(height: 10),
            pw.Text('Montant: ${CurrencyService.fmtPrice(_document!.amount!)}', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          if (_document!.content != null && _document!.content!.isNotEmpty)
            pw.Text(_document!.content!, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 20),
          pw.Text('Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _shareDocument() {
    if (_document == null) return;
    final text = '${_document!.title}\n\nType: ${_document!.typeLabel}\nStatut: ${_document!.statusLabel}\n\n${_document!.content ?? ''}';
    SharePlus.instance.share(ShareParams(text: text, subject: _document!.title));
  }

  void _copyContent() {
    if (_document?.content == null) return;
    Clipboard.setData(ClipboardData(text: _document!.content!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contenu copié !'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
      );
    }
    if (_document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: Text('Document non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Modifier' : 'Détails'),
        actions: [
          if (_editing)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges)
          else ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _editing = true)),
            IconButton(icon: const Icon(Icons.share), onPressed: _shareDocument),
            PopupMenuButton(
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 20), SizedBox(width: 8), Text('Générer PDF')])),
                const PopupMenuItem(value: 'copy', child: Row(children: [Icon(Icons.copy, size: 20), SizedBox(width: 8), Text('Copier le contenu')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.primaryRed), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: AppColors.primaryRed))])),
              ],
              onSelected: (v) {
                if (v == 'pdf') _generatePdf();
                if (v == 'copy') _copyContent();
                if (v == 'delete') _deleteDocument();
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _editing ? _buildEditForm() : _buildDetailView(),
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_document!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBadge(_document!.typeLabel, AppColors.primaryTeal),
                  const SizedBox(width: 8),
                  _buildBadge(_document!.statusLabel, _getStatusColor(_document!.status)),
                ],
              ),
              if (_document!.clientName != null && _document!.clientName!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.person_outline, size: 18, color: Colors.grey), const SizedBox(width: 8), Text(_document!.clientName!, style: const TextStyle(fontSize: 14))]),
              ],
              if (_document!.amount != null) ...[
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.monetization_on, size: 18, color: AppColors.primaryTeal), const SizedBox(width: 8), Text(CurrencyService.fmtPrice(_document!.amount!), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryTeal))]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_document!.content != null && _document!.content!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contenu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                Text(_document!.content!, style: const TextStyle(fontSize: 14, height: 1.6)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Text('Créé le ${_document!.createdAt.day}/${_document!.createdAt.month}/${_document!.createdAt.year} • Modifié le ${_document!.updatedAt.day}/${_document!.updatedAt.month}/${_document!.updatedAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditField(label: 'Titre', controller: _titleController),
        const SizedBox(height: 16),
        _buildEditField(label: 'Client', controller: _clientController),
        const SizedBox(height: 16),
        _buildEditField(label: 'Montant', controller: _amountController, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        const Text('Contenu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 12,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField({required String label, required TextEditingController controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'brouillon': return const Color(0xFFF5A623);
      case 'finalise': return const Color(0xFF4CAF50);
      case 'archive': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _clientController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
