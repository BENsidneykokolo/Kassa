import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/document.dart';
import '../../models/template.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedType = 'facture';
  String _selectedStatus = 'brouillon';
  DocTemplate? _selectedTemplate;
  List<DocTemplate> _templates = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await DatabaseHelper.instance.getAllTemplates();
    setState(() => _templates = templates);
  }

  void _applyTemplate(DocTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _selectedType = template.type;
      _contentController.text = template.content;
      if (_titleController.text.isEmpty) {
        _titleController.text = template.name;
      }
    });
  }

  Future<void> _saveDocument() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final doc = Document(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        templateId: _selectedTemplate?.id,
        type: _selectedType,
        status: _selectedStatus,
        clientName: _clientController.text.trim().isEmpty ? null : _clientController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()),
      );

      final id = await DatabaseHelper.instance.insertDocument(doc);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document créé avec succès !'), backgroundColor: Colors.green),
        );
        context.push('/documents/$id');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau document'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveDocument,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTemplateSection(),
            const SizedBox(height: 20),
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              const Text('Utiliser un template', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          if (_templates.isEmpty)
            const Text('Aucun template disponible', style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.map((t) => ActionChip(
                label: Text(t.name, style: const TextStyle(fontSize: 12)),
                avatar: Icon(_getTemplateIcon(t.type), size: 16),
                backgroundColor: _selectedTemplate?.id == t.id ? AppColors.primaryTeal.withValues(alpha: 0.1) : Colors.grey[100],
                side: BorderSide(color: _selectedTemplate?.id == t.id ? AppColors.primaryTeal : Colors.grey[300]!),
                onPressed: () => _applyTemplate(t),
              )).toList(),
            ),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(String type) {
    switch (type) {
      case 'facture': return Icons.receipt;
      case 'devis': return Icons.request_quote;
      case 'contrat': return Icons.gavel;
      case 'bon': return Icons.shopping_cart;
      case 'recu': return Icons.payment;
      case 'lettre': return Icons.mail;
      default: return Icons.description;
    }
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails du document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        _buildTextField(controller: _titleController, label: 'Titre du document', hint: 'Ex: Facture pour client X', icon: Icons.title),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Type de document',
          value: _selectedType,
          items: const [
            DropdownMenuItem(value: 'facture', child: Text('Facture')),
            DropdownMenuItem(value: 'devis', child: Text('Devis')),
            DropdownMenuItem(value: 'contrat', child: Text('Contrat')),
            DropdownMenuItem(value: 'bon', child: Text('Bon de commande')),
            DropdownMenuItem(value: 'recu', child: Text('Reçu')),
            DropdownMenuItem(value: 'lettre', child: Text('Lettre')),
            DropdownMenuItem(value: 'autre', child: Text('Autre')),
          ],
          onChanged: (v) { if (v != null) setState(() => _selectedType = v); },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Statut',
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: 'brouillon', child: Text('Brouillon')),
            DropdownMenuItem(value: 'finalise', child: Text('Finalisé')),
            DropdownMenuItem(value: 'archive', child: Text('Archivé')),
          ],
          onChanged: (v) { if (v != null) setState(() => _selectedStatus = v); },
        ),
        const SizedBox(height: 16),
        _buildTextField(controller: _clientController, label: 'Nom du client (optionnel)', hint: 'Ex: Entreprise ABC', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(controller: _amountController, label: 'Montant (optionnel)', hint: 'Ex: 50000', icon: Icons.monetization_on, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildContentField(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contenu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Saisissez le contenu du document...\n\nUtilisez {{variable}} pour les variables',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _amountController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
