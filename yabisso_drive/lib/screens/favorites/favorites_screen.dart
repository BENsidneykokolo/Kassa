import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final db = DatabaseHelper.instance;
    final files = await db.getFavoriteFiles();
    if (mounted) setState(() => _favorites = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucun favori', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Ajoutez des fichiers en favoris pour les retrouver facilement', style: TextStyle(fontSize: 13, color: Colors.grey[400]), textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) => _buildFavoriteItem(_favorites[index]),
            ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> file) {
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
        onTap: () => context.go('/files/$id'),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_formatSize(sizeBytes), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: IconButton(
          icon: const Icon(Icons.star, color: AppColors.primaryAmber),
          onPressed: () async {
            await DatabaseHelper.instance.toggleFavorite(id!, false);
            _loadFavorites();
          },
        ),
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
