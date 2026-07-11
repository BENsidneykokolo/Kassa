import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../services/pack_service.dart';

class PackScreen extends StatefulWidget {
  const PackScreen({super.key});

  @override
  State<PackScreen> createState() => _PackScreenState();
}

class _PackScreenState extends State<PackScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isCreatingTaskPack = false;
  String? _lastExportPath;
  String? _statusMessage;
  bool _isError = false;

  // Task creation fields
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  String _taskPriority = 'medium';
  String _taskType = 'general';
  DateTime? _taskDueDate;

  Future<void> _exportPack() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Préparation du pack Admin...';
      _isError = false;
    });

    final result = await PackService.exportPack();

    setState(() {
      _isExporting = false;
      if (result.success) {
        _lastExportPath = result.filePath;
        _statusMessage = 'Pack exporté avec succès !\n${result.recordCount} enregistrements';
        _isError = false;
      } else {
        _statusMessage = 'Erreur : ${result.error}';
        _isError = true;
      }
    });
  }

  Future<void> _importPack() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yabissopack', 'zip'],
    );

    if (picked == null || picked.files.isEmpty) return;

    final filePath = picked.files.first.path;
    if (filePath == null) {
      setState(() {
        _statusMessage = 'Erreur : chemin invalide';
        _isError = true;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: const Text('Importer ce pack ?'),
        content: const Text('Les données actuelles seront remplacées.\nCette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Importer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isImporting = true;
      _statusMessage = 'Importation en cours...';
      _isError = false;
    });

    final result = await PackService.importPack(filePath);

    setState(() {
      _isImporting = false;
      if (result.success) {
        _statusMessage = 'Pack importé !\n${result.recordCount} enregistrements depuis ${result.appName}';
        _isError = false;
      } else {
        _statusMessage = 'Erreur : ${result.error}';
        _isError = true;
      }
    });
  }

  Future<void> _sharePack() async {
    if (_lastExportPath == null) return;
    await Share.shareXFiles(
      [XFile(_lastExportPath!)],
      text: 'Pack Admin - Backup complet',
    );
  }

  void _showCreateTaskPackDialog() {
    _taskTitleController.clear();
    _taskDescController.clear();
    _taskPriority = 'medium';
    _taskType = 'general';
    _taskDueDate = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créer un pack de tâches',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Envoyer des tâches aux employés via un pack',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de la tâche',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taskDescController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _taskPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Basse')),
                          DropdownMenuItem(value: 'medium', child: Text('Moyenne')),
                          DropdownMenuItem(value: 'high', child: Text('Haute')),
                        ],
                        onChanged: (v) => setModalState(() => _taskPriority = v ?? 'medium'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _taskType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'general', child: Text('Général')),
                          DropdownMenuItem(value: 'prospection', child: Text('Prospection')),
                          DropdownMenuItem(value: 'vente', child: Text('Vente')),
                          DropdownMenuItem(value: 'stock', child: Text('Stock')),
                        ],
                        onChanged: (v) => setModalState(() => _taskType = v ?? 'general'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setModalState(() => _taskDueDate = date);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_taskDueDate != null
                      ? 'Échéance : ${_taskDueDate!.day}/${_taskDueDate!.month}/${_taskDueDate!.year}'
                      : 'Choisir une échéance'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    if (_taskTitleController.text.isEmpty) return;

                    final task = {
                      'id': const Uuid().v4(),
                      'title': _taskTitleController.text,
                      'description': _taskDescController.text,
                      'task_type': _taskType,
                      'priority': _taskPriority,
                      'due_date': _taskDueDate?.toIso8601String(),
                      'status': 'todo',
                      'created_at': DateTime.now().toIso8601String(),
                      'assigned_by': 'admin',
                    };

                    Navigator.pop(ctx);

                    setState(() {
                      _isCreatingTaskPack = true;
                      _statusMessage = 'Création du pack de tâches...';
                      _isError = false;
                    });

                    final result = await PackService.createTaskPack(tasks: [task]);

                    setState(() {
                      _isCreatingTaskPack = false;
                      if (result.success) {
                        _lastExportPath = result.filePath;
                        _statusMessage = 'Pack de tâches créé !\nPartagez-le avec vos employés';
                        _isError = false;
                      } else {
                        _statusMessage = 'Erreur : ${result.error}';
                        _isError = true;
                      }
                    });
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Créer et envoyer le pack'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import / Export Pack'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF378ADD), Color(0xFF2870C4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Pack Admin',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérez les packs de données et envoyez des tâches',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Contenu du pack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(Icons.people, 'Employés, profils, documents'),
                    _buildInfoItem(Icons.task, 'Tâches, objectifs, formations'),
                    _buildInfoItem(Icons.assessment, 'Ventes, rapports, présences'),
                    _buildInfoItem(Icons.psychology, 'Propositions IA, notes managers'),
                    _buildInfoItem(Icons.history, 'Journal d\'activité, logs'),
                    _buildInfoItem(Icons.folder, 'CVs, photos, preuves de tâches'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isError ? Colors.red.shade200 : Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: _isError ? Colors.red : Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _isError ? Colors.red.shade700 : Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Send Task Pack button (highlighted)
            Card(
              color: const Color(0xFF378ADD).withValues(alpha: 0.05),
              child: InkWell(
                onTap: _isCreatingTaskPack ? null : _showCreateTaskPackDialog,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF378ADD).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isCreatingTaskPack
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send, color: Color(0xFF378ADD), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCreatingTaskPack ? 'Création...' : 'Envoyer des tâches',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Créer un pack de tâches pour les employés',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF378ADD)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Export
            _buildActionButton(
              icon: Icons.upload_file,
              label: 'Exporter le pack',
              subtitle: 'Sauvegarder toutes les données Admin',
              color: const Color(0xFF1D9E75),
              isLoading: _isExporting,
              loadingText: 'Export en cours...',
              onPressed: _exportPack,
            ),
            const SizedBox(height: 12),

            // Share
            if (_lastExportPath != null)
              _buildActionButton(
                icon: Icons.share,
                label: 'Partager le pack',
                subtitle: 'Envoyer via WhatsApp, email, etc.',
                color: const Color(0xFF378ADD),
                onPressed: _sharePack,
              ),
            if (_lastExportPath != null) const SizedBox(height: 12),

            // Import
            _buildActionButton(
              icon: Icons.download,
              label: 'Importer un pack',
              subtitle: 'Restaurer les données depuis un pack',
              color: const Color(0xFFF5A623),
              isLoading: _isImporting,
              loadingText: 'Import en cours...',
              onPressed: _importPack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    bool isLoading = false,
    String? loadingText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                    : Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? (loadingText ?? label) : label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
