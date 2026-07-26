import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class FilesScreen extends StatefulWidget {
  final String? folderId;
  const FilesScreen({super.key, this.folderId});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<Map<String, dynamic>> _files = [];
  bool _isGridView = true;
  String _sortBy = 'name';
  bool _sortAscending = true;
  String? _currentFolderId;
  List<String> _folderPath = [];
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentFolderId = widget.folderId;
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final db = DatabaseHelper.instance;
    List<Map<String, dynamic>> files;
    if (_isSearching && _searchController.text.isNotEmpty) {
      files = await db.searchFiles(_searchController.text);
    } else if (_currentFolderId != null) {
      files = await db.getFilesByFolder(_currentFolderId);
    } else {
      files = await db.getAllFiles();
    }
    files.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'date': cmp = (a['created_at'] ?? '').compareTo(b['created_at'] ?? ''); break;
        case 'size': cmp = ((a['size_bytes'] as num?) ?? 0).compareTo((b['size_bytes'] as num?) ?? 0); break;
        default: cmp = (a['name'] ?? '').compareTo(b['name'] ?? '');
      }
      return _sortAscending ? cmp : -cmp;
    });
    if (mounted) setState(() => _files = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Rechercher...', hintStyle: TextStyle(color: Colors.white70), border: InputBorder.none),
                onChanged: (_) => _loadFiles(),
              )
            : Text(_currentFolderId != null ? (_folderPath.isNotEmpty ? _folderPath.last : 'Dossier') : 'Mes fichiers'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
              _loadFiles();
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'sort_name') setState(() { _sortBy = 'name'; _sortAscending = true; });
              if (v == 'sort_date') setState(() { _sortBy = 'date'; _sortAscending = false; });
              if (v == 'sort_size') setState(() { _sortBy = 'size'; _sortAscending = false; });
              _loadFiles();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'sort_name', child: Text('Trier par nom')),
              const PopupMenuItem(value: 'sort_date', child: Text('Trier par date')),
              const PopupMenuItem(value: 'sort_size', child: Text('Trier par taille')),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'folder',
            onPressed: _showCreateFolderDialog,
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'import',
            onPressed: _importFiles,
            child: const Icon(Icons.file_upload_outlined),
          ),
        ],
      ),
      body: _files.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(_isSearching ? 'Aucun résultat' : 'Aucun fichier', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Appuyez sur + pour ajouter des fichiers', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            )
          : _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 500 ? 4 : 3,
        crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) => _buildGridItem(_files[index]),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> file) {
    final type = file['type'] as String? ?? 'file';
    final name = file['name'] as String? ?? '';
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

    return GestureDetector(
      onTap: () {
        if (type == 'folder') {
          setState(() {
            _currentFolderId = id.toString();
            _folderPath.add(name);
          });
          _loadFiles();
        } else {
          context.go('/files/$id');
        }
      },
      onLongPress: () => _showContextMenu(file),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _files.length,
      itemBuilder: (context, index) => _buildListItem(_files[index]),
    );
  }

  Widget _buildListItem(Map<String, dynamic> file) {
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
        onTap: () {
          if (type == 'folder') {
            setState(() { _currentFolderId = id.toString(); _folderPath.add(name); });
            _loadFiles();
          } else {
            context.go('/files/$id');
          }
        },
        onLongPress: () => _showContextMenu(file),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(type == 'folder' ? 'Dossier' : _formatSize(sizeBytes), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> file) {
    final id = file['id'] as int?;
    final name = file['name'] as String? ?? '';
    final isFav = (file['is_favorite'] as int?) == 1;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            ListTile(leading: Icon(isFav ? Icons.star : Icons.star_outline), title: Text(isFav ? 'Retirer des favoris' : 'Ajouter aux favoris'), onTap: () async {
              Navigator.pop(ctx);
              if (id != null) await DatabaseHelper.instance.toggleFavorite(id, !isFav);
              _loadFiles();
            }),
            ListTile(leading: const Icon(Icons.edit), title: const Text('Renommer'), onTap: () { Navigator.pop(ctx); _showRenameDialog(file); }),
            ListTile(leading: const Icon(Icons.drive_file_rename_outline), title: const Text('Déplacer'), onTap: () { Navigator.pop(ctx); _showMoveDialog(file); }),
            ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.primaryRed), title: const Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)), onTap: () async {
              Navigator.pop(ctx);
              if (id != null) await DatabaseHelper.instance.deleteFile(id);
              _loadFiles();
            }),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau dossier'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Nom du dossier', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await DatabaseHelper.instance.insertFile({
                'name': name, 'type': 'folder', 'parent_folder_id': _currentFolderId,
                'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _loadFiles();
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;
      final db = DatabaseHelper.instance;
      for (final file in result.files) {
        String type = 'file';
        final ext = p.extension(file.name).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext)) type = 'image';
        else if (['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.csv'].contains(ext)) type = 'document';
        else if (['.mp4', '.avi', '.mov', '.mkv', '.flv', '.wmv'].contains(ext)) type = 'video';
        else if (['.mp3', '.wav', '.ogg', '.aac', '.flac', '.m4a'].contains(ext)) type = 'audio';

        await db.insertFile({
          'name': file.name, 'path': file.path, 'type': type,
          'size_bytes': file.size, 'mimeType': file.extension,
          'parent_folder_id': _currentFolderId,
          'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String(),
        });
      }
      _loadFiles();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  void _showRenameDialog(Map<String, dynamic> file) {
    final controller = TextEditingController(text: file['name'] as String? ?? '');
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
              await DatabaseHelper.instance.updateFile(file['id'], {'name': name});
              if (ctx.mounted) Navigator.pop(ctx);
              _loadFiles();
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(Map<String, dynamic> file) async {
    final db = DatabaseHelper.instance;
    final folders = await db.getFilesByFolder(null);
    final folderList = folders.where((f) => f['type'] == 'folder' && f['id'] != file['id']).toList();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Déplacer vers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Racine'),
              onTap: () async {
                Navigator.pop(ctx);
                await DatabaseHelper.instance.updateFile(file['id'], {'parent_folder_id': null});
                _loadFiles();
              },
            ),
            ...folderList.map((f) => ListTile(
              leading: const Icon(Icons.folder),
              title: Text(f['name'] as String? ?? ''),
              onTap: () async {
                Navigator.pop(ctx);
                await DatabaseHelper.instance.updateFile(file['id'], {'parent_folder_id': f['id'].toString()});
                _loadFiles();
              },
            )),
          ],
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
