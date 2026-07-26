import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/file_item.dart';

class FileDetailScreen extends StatefulWidget {
  final int fileId;
  const FileDetailScreen({super.key, required this.fileId});

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  FileItem? _file;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final db = DatabaseHelper.instance;
    final result = await (await db.database).query('files', where: 'id = ?', whereArgs: [widget.fileId]);
    if (result.isNotEmpty && mounted) {
      setState(() {
        _file = FileItem.fromMap(result.first);
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(title: const Text('Chargement...')), body: const Center(child: CircularProgressIndicator()));
    }
    if (_file == null) {
      return Scaffold(appBar: AppBar(title: const Text('Erreur')), body: const Center(child: Text('Fichier introuvable')));
    }

    final file = _file!;
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        actions: [
          IconButton(
            icon: Icon(file.isFavorite ? Icons.star : Icons.star_outline),
            onPressed: () async {
              await DatabaseHelper.instance.toggleFavorite(file.id!, !file.isFavorite);
              _loadFile();
            },
          ),
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(value: 'share', child: const Row(children: [Icon(Icons.share, size: 20), SizedBox(width: 8), Text('Partager')])),
              PopupMenuItem(value: 'rename', child: const Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Renommer')])),
              PopupMenuItem(value: 'delete', child: Row(children: const [Icon(Icons.delete, size: 20, color: AppColors.primaryRed), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: AppColors.primaryRed))])),
            ],
            onSelected: (v) {
              if (v == 'share') _shareFile();
              if (v == 'rename') _showRenameDialog();
              if (v == 'delete') _deleteFile();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFileIcon(file),
            const SizedBox(height: 24),
            _buildInfoRow('Nom', file.name),
            _buildInfoRow('Type', file.typeLabel),
            _buildInfoRow('Taille', file.sizeLabel),
            _buildInfoRow('Créé le', '${file.createdAt.day}/${file.createdAt.month}/${file.createdAt.year}'),
            _buildInfoRow('Modifié le', '${file.updatedAt.day}/${file.updatedAt.month}/${file.updatedAt.year}'),
            if (file.mimeType != null) _buildInfoRow('Format', file.mimeType!),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareFile,
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleFavorite(),
                    icon: Icon(file.isFavorite ? Icons.star : Icons.star_outline),
                    label: Text(file.isFavorite ? 'Favori' : 'Favoris'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteFile,
                icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
                label: const Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(FileItem file) {
    IconData icon;
    Color color;
    switch (file.type) {
      case 'folder': icon = Icons.folder; color = AppColors.primaryAmber; break;
      case 'image': icon = Icons.image; color = AppColors.primaryGreen; break;
      case 'document': icon = Icons.description; color = AppColors.primaryBlue; break;
      case 'video': icon = Icons.videocam; color = AppColors.primaryRed; break;
      case 'audio': icon = Icons.audiotrack; color = const Color(0xFF9B59B6); break;
      default: icon = Icons.insert_drive_file; color = AppColors.grey; break;
    }
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
      child: Icon(icon, color: color, size: 50),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }

  void _shareFile() {
    if (_file!.path != null) {
      SharePlus.instance.share(ShareParams(files: [_file!.path!]));
    } else {
      SharePlus.instance.share(ShareParams(text: _file!.name));
    }
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper.instance.toggleFavorite(_file!.id!, !_file!.isFavorite);
    _loadFile();
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _file!.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await DatabaseHelper.instance.updateFile(_file!.id!, {'name': name});
              if (ctx.mounted) Navigator.pop(ctx);
              _loadFile();
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  void _deleteFile() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce fichier ?'),
        content: const Text('Le fichier sera déplacé vers la corbeille.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteFile(_file!.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) context.go('/files');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
