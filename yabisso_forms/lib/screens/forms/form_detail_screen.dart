import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_template.dart';

class FormDetailScreen extends StatefulWidget {
  final int formId;
  const FormDetailScreen({super.key, required this.formId});

  @override
  State<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailScreen> {
  FormTemplate? _template;
  List<Map<String, dynamic>> _fields = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    final db = DatabaseHelper.instance;
    final template = await db.getFormTemplateById(widget.formId);
    if (template != null) {
      final fields = db.parseFieldsJson(template.fieldsJson);
      if (mounted) {
        setState(() {
          _template = template;
          _fields = fields;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_template == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Formulaire introuvable')),
        body: const Center(child: Text('Ce formulaire n\'existe pas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_template!.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editForm();
                  break;
                case 'share':
                  _shareForm();
                  break;
                case 'delete':
                  _deleteForm();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
              const PopupMenuItem(value: 'share', child: Text('Partager')),
              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            _buildFieldsPreview(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryOrange.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _template!.typeLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_fields.length} champ(s)',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _template!.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (_template!.description != null && _template!.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _template!.description!,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.question_answer,
            label: 'Réponses',
            value: _template!.responseCount.toString(),
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            icon: Icons.list_alt,
            label: 'Champs',
            value: _fields.length.toString(),
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu des champs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          ..._fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return _buildFieldPreview(field, index);
          }),
        ],
      ),
    );
  }

  Widget _buildFieldPreview(Map<String, dynamic> field, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['label'] ?? 'Sans nom',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  _getFieldTypeLabel(field['type'] ?? 'text'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (field['required'] == true)
            const Icon(Icons.star, size: 14, color: AppColors.primaryRed),
        ],
      ),
    );
  }

  String _getFieldTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Texte libre';
      case 'number':
        return 'Nombre';
      case 'choice':
        return 'Choix multiple';
      case 'date':
        return 'Date';
      case 'rating':
        return 'Évaluation';
      default:
        return type;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/forms/${_template!.id}/fill'),
            icon: const Icon(Icons.edit_note, size: 22),
            label: const Text('Remplir ce formulaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/forms/${_template!.id}/responses'),
            icon: const Icon(Icons.question_answer, size: 22),
            label: const Text('Voir les réponses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _shareForm,
            icon: const Icon(Icons.share, size: 22),
            label: const Text('Partager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _shareForm() {
    final fieldsText = _fields.map((f) => '- ${f['label']} (${_getFieldTypeLabel(f['type'] ?? 'text')})').join('\n');
    final text = '📋 Formulaire: ${_template!.name}\n'
        '📝 Type: ${_template!.typeLabel}\n'
        '📊 Champs:\n$fieldsText\n'
        '🔗 Remplir: [lien du formulaire]';
    Share.share(text, subject: _template!.name);
  }

  void _deleteForm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le formulaire ?'),
        content: const Text('Cette action est irréversible. Toutes les réponses seront supprimées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.deleteFormTemplate(_template!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulaire supprimé'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  void _editForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modification en cours de développement'), backgroundColor: Colors.orange),
    );
  }
}
