import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Map<String, dynamic>> _deletedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedFiles();
  }

  Future<void> _loadDeletedFiles() async {
    final db = DatabaseHelper.instance;
    final files = await db.getDeletedFiles();
    if (mounted) setState(() => _deletedFiles = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corbeille'),
        actions: [
          if (_deletedFiles.isNotEmpty)
            TextButton(
              onPressed: _emptyTrash,
              child: const Text('Vider', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _deletedFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('La corbeille est vide', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deletedFiles.length,
              itemBuilder: (context, index) => _buildDeletedItem(_deletedFiles[index]),
            ),
    );
  }

  Widget _buildDeletedItem(Map<String, dynamic> file) {
    final type = file['type'] as String? ?? 'file';
    final name = file['name'] as String? ?? '';
    final sizeBytes = (file['size_bytes'] as num?)?.toDouble() ?? 0;
    final id = file['id'] as int?;

    IconData icon;
    Color color;
    switch (type) {
      case 'folder': icon = Icons.folder; color = AppColors.primaryAmber; break;
      case 'image': icon = Icons.image; color = AppColors.primaryGreen; break;
      case 'document': icon = Icons.description; color = AppColors.primaryBlue; break;
      case 'video': icon = Icons.videocam; color = AppColors.primaryRed; break;
      case 'audio': icon = Icons.audiotrack; color = const Color(0xFF9B59B6); break;
      default: icon = Icons.insert_drive_file; color = AppColors.grey; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_formatSize(sizeBytes), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore, color: AppColors.primaryGreen),
              onPressed: () async {
                await DatabaseHelper.instance.restoreFile(id!);
                _loadDeletedFiles();
              },
              tooltip: 'Restaurer',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.primaryRed),
              onPressed: () => _confirmPermanentDelete(id!),
              tooltip: 'Supprimer définitivement',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPermanentDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer définitivement ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.permanentDeleteFile(id);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadDeletedFiles();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _emptyTrash() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider la corbeille ?'),
        content: const Text('Tous les fichiers seront supprimés définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final db = DatabaseHelper.instance;
              for (final file in _deletedFiles) {
                await db.permanentDeleteFile(file['id']);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _loadDeletedFiles();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Vider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatSize(double bytes) {
    if (bytes < 1024) return '${bytes.round()} B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
}
