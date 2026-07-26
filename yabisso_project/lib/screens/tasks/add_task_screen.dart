import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final int? projectId;
  const AddTaskScreen({super.key, this.projectId});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedProjectId;
  String _priority = 'moyenne';
  DateTime? _dueDate;
  String? _selectedAssignee;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _teamMembers = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    _loadData();
  }

  Future<void> _loadData() async {
    final projects = await DatabaseHelper.instance.getAllProjects();
    final members = await DatabaseHelper.instance.getAllTeamMembers();
    setState(() {
      _projects = projects;
      _teamMembers = members;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un projet'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final task = {
      'project_id': _selectedProjectId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': 'a_faire',
      'priority': _priority,
      'due_date': _dueDate?.toIso8601String(),
      'assignee': _selectedAssignee,
    };

    await DatabaseHelper.instance.insertTask(task);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Titre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ex: Designer la maquette',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Décrivez la tâche...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Projet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedProjectId,
                    hint: const Text('Sélectionner un projet'),
                    isExpanded: true,
                    items: _projects
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p['id'] as int,
                            child: Text(p['name'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProjectId = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assigné à',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAssignee,
                    hint: const Text('Sélectionner un membre'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Non assigné'),
                      ),
                      ..._teamMembers
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m['name'] as String,
                              child: Text(m['name'] as String),
                            ),
                          ),
                    ],
                    onChanged: (v) => setState(() => _selectedAssignee = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Priorité',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              _buildPrioritySelector(),
              const SizedBox(height: 16),
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _dueDate != null
                            ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? AppColors.textDark
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Créer la tâche',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final options = [
      ('haute', 'Haute', AppColors.primaryRed),
      ('moyenne', 'Moyenne', AppColors.primaryAmber),
      ('basse', 'Basse', AppColors.primaryGreen),
    ];

    return Row(
      children: options.map((opt) {
        final selected = _priority == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = opt.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? opt.$3.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? opt.$3 : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? opt.$3 : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? opt.$3 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
