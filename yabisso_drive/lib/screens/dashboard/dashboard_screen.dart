import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../files/files_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _totalFiles = 0;
  int _totalFolders = 0;
  double _totalStorage = 0;
  double _maxStorage = 5368709120; // 5 GB
  String _storeName = 'Mon Drive';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseHelper.instance;
    final files = await db.getFileCount();
    final folders = await db.getFolderCount();
    final storage = await db.getTotalStorageUsed();
    final storeNameSetting = await db.getSetting('store_name');
    if (mounted) {
      setState(() {
        _totalFiles = files;
        _totalFolders = folders;
        _totalStorage = storage;
        if (storeNameSetting != null) _storeName = storeNameSetting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const _FilesTab(),
      const _FavoritesTab(),
      const _TrashTab(),
      const _SettingsTab(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 1) { context.go('/files'); return; }
          if (index == 2) { context.go('/favorites'); return; }
          if (index == 3) { context.go('/trash'); return; }
          if (index == 4) { context.go('/settings'); return; }
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Fichiers'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.delete_outline), selectedIcon: Icon(Icons.delete), label: 'Corbeille'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStorageCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildRecentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.folder, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bonjour !', style: TextStyle(fontSize: 14, color: AppColors.grey)),
              const SizedBox(height: 2),
              Text(_storeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildStorageCard() {
    final usagePercent = (_totalStorage / _maxStorage).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlue.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Espace de stockage', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('$_totalFiles', 'Fichiers'),
              _buildStatItem('$_totalFolders', 'Dossiers'),
              _buildStatItem(_formatSize(_totalStorage), 'Utilisé'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('${_formatSize(_totalStorage)} / ${_formatSize(_maxStorage)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildActionCard(Icons.create_new_folder, 'Nouveau\ndossier', AppColors.primaryBlue, () => context.go('/files')),
            const SizedBox(width: 12),
            _buildActionCard(Icons.file_upload_outlined, 'Importer\nfichier', AppColors.primaryGreen, () => context.go('/files')),
            const SizedBox(width: 12),
            _buildActionCard(Icons.history, 'Récents', AppColors.primaryAmber, () => context.go('/recent')),
            const SizedBox(width: 12),
            _buildActionCard(Icons.star_outline, 'Favoris', AppColors.primaryRed, () => context.go('/favorites')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fichiers récents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            TextButton(onPressed: () => context.go('/recent'), child: const Text('Voir tout')),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getRecentFiles(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final files = snapshot.data!;
            if (files.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Aucun fichier récent', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              );
            }
            return Column(
              children: files.take(5).map((f) => _buildFileListItem(f)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFileListItem(Map<String, dynamic> file) {
    final type = file['type'] as String? ?? 'file';
    final name = file['name'] as String? ?? '';
    final sizeBytes = (file['size_bytes'] as num?)?.toDouble() ?? 0;

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'folder': icon = Icons.folder; iconColor = AppColors.primaryAmber; break;
      case 'image': icon = Icons.image; iconColor = AppColors.primaryGreen; break;
      case 'document': icon = Icons.description; iconColor = AppColors.primaryBlue; break;
      case 'video': icon = Icons.videocam; iconColor = AppColors.primaryRed; break;
      case 'audio': icon = Icons.audiotrack; iconColor = const Color(0xFF9B59B6); break;
      default: icon = Icons.insert_drive_file; iconColor = AppColors.grey; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${type == 'folder' ? 'Dossier' : _formatSize(sizeBytes)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
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

class _FilesTab extends StatelessWidget {
  const _FilesTab();
  @override
  Widget build(BuildContext context) {
    return const FilesScreen();
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context) {
    context.go('/favorites');
    return const SizedBox.shrink();
  }
}

class _TrashTab extends StatelessWidget {
  const _TrashTab();
  @override
  Widget build(BuildContext context) {
    context.go('/trash');
    return const SizedBox.shrink();
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();
  @override
  Widget build(BuildContext context) {
    context.go('/settings');
    return const SizedBox.shrink();
  }
}
