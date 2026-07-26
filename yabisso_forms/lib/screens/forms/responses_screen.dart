import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_response.dart';
import '../../models/form_template.dart';

class ResponsesScreen extends StatefulWidget {
  final int formId;
  const ResponsesScreen({super.key, required this.formId});

  @override
  State<ResponsesScreen> createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  FormTemplate? _template;
  List<Map<String, dynamic>> _fields = [];
  List<FormResponse> _responses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final template = await db.getFormTemplateById(widget.formId);
    if (template != null) {
      final fields = db.parseFieldsJson(template.fieldsJson);
      final responses = await db.getResponsesByFormId(widget.formId);
      if (mounted) {
        setState(() {
          _template = template;
          _fields = fields;
          _responses = responses;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Réponses')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Réponses - ${_template?.name ?? ''}'),
        actions: [
          if (_responses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportResponses,
              tooltip: 'Exporter',
            ),
        ],
      ),
      body: _responses.isEmpty ? _buildEmptyState() : _buildResponsesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune réponse',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Partagez ce formulaire pour recevoir des réponses',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    return Column(
      children: [
        _buildSummaryHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _responses.length,
            itemBuilder: (context, index) {
              return _buildResponseCard(_responses[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.primaryOrange,
      child: Row(
        children: [
          const Icon(Icons.question_answer, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_responses.length} réponse(s)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                _template?.name ?? '',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(FormResponse response, int index) {
    final answers = _parseAnswers(response.answersJson);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.respondentName ?? 'Anonyme',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (response.respondentPhone != null)
                        Text(
                          response.respondentPhone!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${response.createdAt.day}/${response.createdAt.month}/${response.createdAt.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 20),
            ..._fields.map((field) {
              final fieldId = field['id'] ?? '';
              final answer = answers[fieldId];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${field['label']}:',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        answer?.toString() ?? '—',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, size: 18, color: AppColors.primaryGreen),
                  onPressed: () => _shareResponse(response, answers),
                  tooltip: 'Partager',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: AppColors.primaryRed),
                  onPressed: () => _deleteResponse(response),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _parseAnswers(String? answersJson) {
    if (answersJson == null || answersJson.isEmpty) return {};
    try {
      final decoded = jsonDecode(answersJson);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  void _shareResponse(FormResponse response, Map<String, dynamic> answers) {
    final buffer = StringBuffer();
    buffer.writeln('📋 Réponse au formulaire: ${_template?.name ?? ''}');
    buffer.writeln('👤 Respondant: ${response.respondentName ?? "Anonyme"}');
    if (response.respondentPhone != null) {
      buffer.writeln('📞 Tél: ${response.respondentPhone}');
    }
    buffer.writeln('📅 Date: ${response.createdAt.day}/${response.createdAt.month}/${response.createdAt.year}');
    buffer.writeln('');
    buffer.writeln('📝 Réponses:');
    for (final field in _fields) {
      final fieldId = field['id'] ?? '';
      final answer = answers[fieldId];
      buffer.writeln('- ${field['label']}: ${answer?.toString() ?? "—"}');
    }
    Share.share(buffer.toString(), subject: 'Réponse - ${_template?.name ?? ''}');
  }

  void _deleteResponse(FormResponse response) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette réponse ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteFormResponse(response.id!);
      _loadData();
    }
  }

  void _exportResponses() {
    final buffer = StringBuffer();
    buffer.writeln('Formulaire: ${_template?.name ?? ""}');
    buffer.writeln('Type: ${_template?.typeLabel ?? ""}');
    buffer.writeln('Nombre de réponses: ${_responses.length}');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');

    for (var i = 0; i < _responses.length; i++) {
      final response = _responses[i];
      final answers = _parseAnswers(response.answersJson);
      buffer.writeln('Réponse #${i + 1}');
      buffer.writeln('Nom: ${response.respondentName ?? "Anonyme"}');
      buffer.writeln('Tél: ${response.respondentPhone ?? "—"}');
      buffer.writeln('Date: ${response.createdAt.day}/${response.createdAt.month}/${response.createdAt.year}');
      for (final field in _fields) {
        final fieldId = field['id'] ?? '';
        final answer = answers[fieldId];
        buffer.writeln('  ${field['label']}: ${answer?.toString() ?? "—"}');
      }
      buffer.writeln('');
    }

    Share.share(buffer.toString(), subject: 'Export réponses - ${_template?.name ?? ""}');
  }
}
