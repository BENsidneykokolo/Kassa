import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/ai_model_service.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});
  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<Map<String, dynamic>> _models = [];
  int? _activeModelId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _loading = true);
    final models = await DatabaseHelper.instance.getAllModels();
    final active = await DatabaseHelper.instance.getActiveModel();
    setState(() {
      _models = models;
      _activeModelId = active?['id'] as int?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Modèles IA'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Modèles Offline', Icons.offline_bolt, 'Fonctionnent sans Internet'),
                  const SizedBox(height: 12),
                  ..._models.where((m) => m['type'] == 'offline').map((m) => _buildModelCard(m)),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Modèles Online', Icons.cloud, 'Nécessitent Internet'),
                  const SizedBox(height: 12),
                  ..._models.where((m) => m['type'] == 'online').map((m) => _buildModelCard(m)),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primaryPurple, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ])),
    ]);
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final isActive = _activeModelId == model['id'];
    final isDownloaded = model['is_downloaded'] == 1;
    final sizeMb = (model['size_mb'] as num?)?.toDouble() ?? 0;
    final isOffline = model['type'] == 'offline';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.primaryPurple : AppColors.border, width: isActive ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isOffline ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(isOffline ? Icons.offline_bolt : Icons.cloud, color: isOffline ? AppColors.primaryGreen : AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(model['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              if (isOffline) Text('${sizeMb.toStringAsFixed(1)} MB', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ])),
            if (isActive) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(6)),
              child: const Text('Actif', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(model['description'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            if (isOffline && !isDownloaded)
              Expanded(child: ElevatedButton.icon(
                onPressed: () => _downloadModel(model),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Télécharger', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)),
              ))
            else if (isOffline || isDownloaded)
              Expanded(child: OutlinedButton.icon(
                onPressed: isActive ? null : () => _activateModel(model['id']),
                icon: Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: isActive ? AppColors.primaryPurple : Colors.grey),
                label: Text(isActive ? 'Utilisé actuellement' : 'Utiliser ce modèle', style: TextStyle(fontSize: 12, color: isActive ? AppColors.primaryPurple : Colors.grey[700])),
                style: OutlinedButton.styleFrom(side: BorderSide(color: isActive ? AppColors.primaryPurple : AppColors.border), padding: const EdgeInsets.symmetric(vertical: 8)),
              ))
            else
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _configureApiKey(model),
                icon: const Icon(Icons.key, size: 16),
                label: const Text('Configurer clé API', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryAmber), foregroundColor: AppColors.primaryAmber, padding: const EdgeInsets.symmetric(vertical: 8)),
              )),
          ]),
        ],
      ),
    );
  }

  Future<void> _downloadModel(Map<String, dynamic> model) async {
    double progress = 0;
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          AiModelService.instance.downloadModel(model['id'], (p) {
            progress = p;
            if (ctx.mounted) setDialogState(() {});
          }).then((success) {
            if (ctx.mounted) Navigator.pop(ctx);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${model["name"]} téléchargé !'), backgroundColor: AppColors.primaryGreen));
              _loadModels();
            }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              CircularProgressIndicator(value: progress, color: AppColors.primaryPurple),
              const SizedBox(height: 16),
              const Text('Téléchargement...', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${(progress * 100).round()}%', style: TextStyle(color: Colors.grey[600])),
            ]),
          );
        },
      ),
    );
  }

  Future<void> _activateModel(int modelId) async {
    await DatabaseHelper.instance.setActiveModel(modelId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modèle activé !'), backgroundColor: AppColors.primaryPurple));
    _loadModels();
  }

  Future<void> _configureApiKey(Map<String, dynamic> model) async {
    final controller = TextEditingController();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clé API - ${model["name"]}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Entrez votre clé API ${model["name"]}:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 12),
          TextField(controller: controller, obscureText: true, decoration: InputDecoration(hintText: 'sk-...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateModelApiKey(model['id'], controller.text.trim());
              await DatabaseHelper.instance.setActiveModel(model['id']);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${model["name"]} configuré !'), backgroundColor: AppColors.primaryGreen));
              _loadModels();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
