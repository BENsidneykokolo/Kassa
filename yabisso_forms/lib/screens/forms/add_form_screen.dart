import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_template.dart';

class AddFormScreen extends StatefulWidget {
  const AddFormScreen({super.key});

  @override
  State<AddFormScreen> createState() => _AddFormScreenState();
}

class _AddFormScreenState extends State<AddFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'autre';
  List<Map<String, dynamic>> _fields = [];
  bool _saving = false;

  final Map<String, String> _typeLabels = {
    'feedback': 'Feedback',
    'commande': 'Commande',
    'inscription': 'Inscription',
    'enquete': 'Enquête',
    'autre': 'Autre',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau formulaire'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveForm,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormInfoSection(),
            const SizedBox(height: 24),
            _buildFieldsSection(),
            const SizedBox(height: 24),
            _buildAddFieldButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInfoSection() {
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
            'Informations du formulaire',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nom du formulaire',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Description (optionnel)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Type de formulaire', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _typeLabels.entries.map((entry) {
              final isSelected = _selectedType == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) => setState(() => _selectedType = entry.key),
                selectedColor: AppColors.primaryOrange,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Champs du formulaire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${_fields.length} champ(s)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_fields.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.add_circle_outline, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Aucun champ ajouté', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Ajoutez des champs pour construire votre formulaire',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _fields.removeAt(oldIndex);
                _fields.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final field = _fields[index];
              return _buildFieldCard(field, index);
            },
          ),
      ],
    );
  }

  Widget _buildFieldCard(Map<String, dynamic> field, int index) {
    return Card(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.drag_handle, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field['label'] ?? 'Sans nom',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getFieldTypeLabel(field['type'] ?? 'text'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (field['required'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Requis', style: TextStyle(fontSize: 10, color: AppColors.primaryRed, fontWeight: FontWeight.w600)),
              ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.primaryBlue),
              onPressed: () => _editField(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: AppColors.primaryRed),
              onPressed: () => setState(() => _fields.removeAt(index)),
            ),
          ],
        ),
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
        return 'Évaluation (étoiles)';
      default:
        return type;
    }
  }

  Widget _buildAddFieldButtons() {
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
            'Ajouter un champ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAddFieldChip(icon: Icons.text_fields, label: 'Texte', type: 'text'),
              _buildAddFieldChip(icon: Icons.numbers, label: 'Nombre', type: 'number'),
              _buildAddFieldChip(icon: Icons.radio_button_checked, label: 'Choix', type: 'choice'),
              _buildAddFieldChip(icon: Icons.calendar_today, label: 'Date', type: 'date'),
              _buildAddFieldChip(icon: Icons.star, label: 'Évaluation', type: 'rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddFieldChip({
    required IconData icon,
    required String label,
    required String type,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primaryOrange),
      label: Text(label),
      onPressed: () => _addField(type),
      backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primaryOrange),
    );
  }

  void _addField(String type) {
    _showFieldDialog(type: type, index: null);
  }

  void _editField(int index) {
    final field = _fields[index];
    _showFieldDialog(type: field['type'], index: index);
  }

  void _showFieldDialog({required String type, int? index}) {
    final labelController = TextEditingController(
      text: index != null ? (_fields[index]['label'] ?? '') : '',
    );
    final hintController = TextEditingController(
      text: index != null ? (_fields[index]['hint'] ?? '') : '',
    );
    bool required = index != null ? (_fields[index]['required'] ?? false) : false;
    List<String> options = index != null ? List<String>.from(_fields[index]['options'] ?? []) : [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(index != null ? 'Modifier le champ' : 'Ajouter un champ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(_getFieldIcon(type), color: AppColors.primaryOrange),
                      const SizedBox(width: 8),
                      Text(_getFieldTypeLabel(type), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    hintText: 'Libellé du champ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hintController,
                  decoration: InputDecoration(
                    hintText: 'Texte d\'aide (optionnel)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.help_outline),
                  ),
                ),
                if (type == 'choice') ...[
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Options', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  ...options.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: entry.value,
                              onChanged: (val) => options[entry.key] = val,
                              decoration: InputDecoration(
                                hintText: 'Option ${entry.key + 1}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.primaryRed),
                            onPressed: () => setDialogState(() => options.removeAt(entry.key)),
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setDialogState(() => options.add('')),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter une option'),
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Champ requis'),
                  value: required,
                  onChanged: (val) => setDialogState(() => required = val),
                  activeColor: AppColors.primaryOrange,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Le libellé est requis'), backgroundColor: Colors.orange),
                  );
                  return;
                }
                final fieldData = {
                  'id': 'field_${DateTime.now().millisecondsSinceEpoch}',
                  'type': type,
                  'label': label,
                  'hint': hintController.text.trim(),
                  'required': required,
                  if (type == 'choice') 'options': options.where((o) => o.isNotEmpty).toList(),
                };
                setState(() {
                  if (index != null) {
                    _fields[index] = fieldData;
                  } else {
                    _fields.add(fieldData);
                  }
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
              child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFieldIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'number':
        return Icons.numbers;
      case 'choice':
        return Icons.radio_button_checked;
      case 'date':
        return Icons.calendar_today;
      case 'rating':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _saveForm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du formulaire est requis'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un champ'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _saving = true);

    final template = FormTemplate(
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      fieldsJson: jsonEncode(_fields),
      type: _selectedType,
    );

    await DatabaseHelper.instance.insertFormTemplate(template);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulaire créé avec succès !'), backgroundColor: Colors.green),
      );
      context.pop();
    }

    setState(() => _saving = false);
  }
}
