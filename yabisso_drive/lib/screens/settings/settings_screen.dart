import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../helpers/whatsapp_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _storeName = 'Mon Drive';
  String _ownerName = '';
  String _storePhone = '';
  double _totalStorage = 0;
  int _totalFiles = 0;
  int _totalFolders = 0;
  String _plan = 'Aucun';
  String _expires = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = DatabaseHelper.instance;
    final storeName = await db.getSetting('store_name');
    final ownerName = await db.getSetting('owner_name');
    final storePhone = await db.getSetting('store_phone');
    final storage = await db.getTotalStorageUsed();
    final files = await db.getFileCount();
    final folders = await db.getFolderCount();
    final prefs = await SharedPreferences.getInstance();
    final plan = prefs.getString('subscription_plan') ?? 'Aucun';
    final expires = prefs.getString('subscription_expires') ?? '';

    if (mounted) {
      setState(() {
        _storeName = storeName ?? 'Mon Drive';
        _ownerName = ownerName ?? '';
        _storePhone = storePhone ?? '';
        _totalStorage = storage;
        _totalFiles = files;
        _totalFolders = folders;
        _plan = plan;
        _expires = expires;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageInfo(),
            const SizedBox(height: 20),
            _buildSubscriptionCard(),
            const SizedBox(height: 20),
            _buildStoreInfo(),
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Espace de stockage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('$_totalFiles', 'Fichiers'),
              _buildStatItem('$_totalFolders', 'Dossiers'),
              _buildStatItem(_formatSize(_totalStorage), 'Utilisé'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mon abonnement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _plan == 'Aucun' ? Colors.grey[200] : AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_plan, style: TextStyle(fontWeight: FontWeight.w600, color: _plan == 'Aucun' ? Colors.grey : AppColors.primaryBlue)),
              ),
              if (_expires.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text('Expire: ${_expires.substring(0, 10)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _openWhatsAppForSubscription,
              child: const Text('Renouveler / Changer de plan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          _buildInfoTile(Icons.store, 'Boutique', _storeName),
          _buildInfoTile(Icons.person, 'Propriétaire', _ownerName.isNotEmpty ? _ownerName : '-'),
          _buildInfoTile(Icons.phone, 'Téléphone', _storePhone.isNotEmpty ? _storePhone : '-'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ])),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          _buildActionTile(Icons.help_outline, 'Aide & Support', () => WhatsAppHelper.openWhatsApp()),
          _buildActionTile(Icons.info_outline, 'À propos', _showAboutDialog),
          _buildActionTile(Icons.logout, 'Se déconnecter', _logout),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _openWhatsAppForSubscription() {
    WhatsAppHelper.showChoice(
      context: context,
      message: Uri.encodeComponent('Bonjour, je souhaite renouveler mon abonnement Yabisso Drive.'),
      groupType: 'subscription',
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Yabisso Drive',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.folder, color: Colors.white, size: 28),
      ),
      children: [
        const Text('Stockage et gestion de fichiers pour commerçants africains.'),
        const SizedBox(height: 16),
        const Text('Développé par Yabisso'),
      ],
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez vous reconnecter pour accéder à votre drive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) context.go('/login');
            },
            child: const Text('Se déconnecter'),
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
