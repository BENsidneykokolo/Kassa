import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _primary = AppColors.primaryGreen;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Général', [
              _buildSwitchTile('Notifications', 'Recevoir les alertes et notifications', Icons.notifications_outlined, _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
              _buildSwitchTile('Mode sombre', 'Interface en mode sombre', Icons.dark_mode_outlined, _darkMode, (v) => setState(() => _darkMode = v)),
              _buildSwitchTile('Sauvegarde auto', 'Sauvegarder les données automatiquement', Icons.backup_outlined, _autoBackup, (v) => setState(() => _autoBackup = v)),
            ]),
            const SizedBox(height: 20),
            _buildSection('Données', [
              _buildActionTile('Exporter les données', 'Télécharger un CSV de toutes les données', Icons.file_download_outlined, () => _showExportDialog()),
              _buildActionTile('Synchroniser', 'Synchroniser avec le serveur', Icons.sync, () => _showSyncDialog()),
              _buildActionTile('Vider le cache', 'Libérer l\'espace de stockage', Icons.delete_outline, () => _showClearCacheDialog()),
            ]),
            const SizedBox(height: 20),
            _buildSection('À propos', [
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('Développé par', 'Yabisso Tech'),
              _buildInfoTile('Contact', 'admin@yabisso.com'),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: _primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _primary,
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text('Voulez-vous exporter toutes les données en format CSV ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export démarré...'), backgroundColor: AppColors.primaryGreen),
              );
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Synchronisation'),
        content: const Text('Synchroniser les données avec le serveur distant ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Synchronisation en cours...'), backgroundColor: AppColors.primaryBlue),
              );
            },
            child: const Text('Synchroniser'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text('Cette action supprimera les données temporaires. Continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache vidé'), backgroundColor: AppColors.successGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}
