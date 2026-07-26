import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_template.dart';
import '../../models/form_response.dart';

class FillFormScreen extends StatefulWidget {
  final int formId;
  const FillFormScreen({super.key, required this.formId});

  @override
  State<FillFormScreen> createState() => _FillFormScreenState();
}

class _FillFormScreenState extends State<FillFormScreen> {
  FormTemplate? _template;
  List<Map<String, dynamic>> _fields = [];
  bool _loading = true;
  bool _submitting = false;
  final Map<String, dynamic> _answers = {};
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

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
        for (final field in _fields) {
          _answers[field['id']] = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
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
        backgroundColor: AppColors.primaryOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRespondentInfo(),
            const SizedBox(height: 24),
            ..._fields.asMap().entries.map((entry) {
              return _buildFieldInput(entry.value);
            }),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 40),
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _template!.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (_template!.description != null && _template!.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _template!.description!,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRespondentInfo() {
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
            'Vos informations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Votre nom (optionnel)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Votre téléphone (optionnel)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(Map<String, dynamic> field) {
    final fieldId = field['id'] ?? '';
    final label = field['label'] ?? '';
    final type = field['type'] ?? 'text';
    final hint = field['hint'] ?? '';
    final required = field['required'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
              if (required)
                const Text('*', style: TextStyle(color: AppColors.primaryRed, fontSize: 16)),
            ],
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          const SizedBox(height: 12),
          _buildInputByType(field, fieldId, type),
        ],
      ),
    );
  }

  Widget _buildInputByType(Map<String, dynamic> field, String fieldId, String type) {
    switch (type) {
      case 'text':
        return TextField(
          onChanged: (val) => _answers[fieldId] = val,
          decoration: InputDecoration(
            hintText: field['hint'] ?? 'Votre réponse',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        );
      case 'number':
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (val) => _answers[fieldId] = val,
          decoration: InputDecoration(
            hintText: field['hint'] ?? '0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        );
      case 'choice':
        final options = List<String>.from(field['options'] ?? []);
        return Column(
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _answers[fieldId],
              onChanged: (val) => setState(() => _answers[fieldId] = val),
              activeColor: AppColors.primaryOrange,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );
      case 'date':
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _answers[fieldId] = '${date.day}/${date.month}/${date.year}';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Text(
                  _answers[fieldId] ?? 'Sélectionner une date',
                  style: TextStyle(
                    color: _answers[fieldId] != null ? AppColors.textDark : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      case 'rating':
        final currentRating = _answers[fieldId] ?? 0;
        return Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: const Color(0xFFF5A623),
                size: 32,
              ),
              onPressed: () => setState(() => _answers[fieldId] = index + 1),
            );
          }),
        );
      default:
        return TextField(
          onChanged: (val) => _answers[fieldId] = val,
          decoration: InputDecoration(
            hintText: 'Votre réponse',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _submitForm,
        icon: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.send, size: 22),
        label: Text(
          _submitting ? 'Envoi en cours...' : 'Envoyer mes réponses',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final requiredFields = _fields.where((f) => f['required'] == true);
    for (final field in requiredFields) {
      final fieldId = field['id'] ?? '';
      final answer = _answers[fieldId];
      if (answer == null || answer.toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le champ "${field['label']}" est requis'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _submitting = true);

    final response = FormResponse(
      formId: widget.formId,
      respondentName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      respondentPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      answersJson: jsonEncode(_answers),
    );

    await DatabaseHelper.instance.insertFormResponse(response);
    await DatabaseHelper.instance.incrementResponseCount(widget.formId);

    if (mounted) {
      setState(() => _submitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 48, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Merci !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vos réponses ont été enregistrées avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
