import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Map<String, dynamic>> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final db = DatabaseHelper.instance;
    final files = await db.getRecentFiles();
    if (mounted) setState(() => _recentFiles = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fichiers récents')),
      body: _recentFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucun fichier récent', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentFiles.length,
              itemBuilder: (context, index) => _buildRecentItem(_recentFiles[index]),
            ),
    );
  }

  Widget _buildRecentItem(Map<String, dynamic> file) {
    final type = file['type'] as String? ?? 'file';
    final name = file['name'] as String? ?? '';
    final sizeBytes = (file['size_bytes'] as num?)?.toDouble() ?? 0;
    final id = file['id'] as int?;
    final updatedAt = file['updated_at'] as String?;

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

    String dateLabel = '';
    if (updatedAt != null) {
      try {
        final dt = DateTime.parse(updatedAt);
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) dateLabel = 'Il y a ${diff.inMinutes} min';
        else if (diff.inHours < 24) dateLabel = 'Il y a ${diff.inHours}h';
        else if (diff.inDays < 7) dateLabel = 'Il y a ${diff.inDays}j';
        else dateLabel = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.go('/files/$id'),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$dateLabel · ${_formatSize(sizeBytes)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
