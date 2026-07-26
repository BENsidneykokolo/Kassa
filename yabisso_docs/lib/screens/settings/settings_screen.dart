import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../helpers/whatsapp_helper.dart';
import '../../services/points_service.dart';
import '../../services/offline_voucher_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _storeName = 'Yabisso Docs';
  String _plan = 'BASIC';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeName = prefs.getString('store_name') ?? 'Yabisso Docs';
      _plan = prefs.getString('subscription_plan') ?? 'BASIC';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _buildSectionHeader('Général'),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Ma Boutique'),
            subtitle: Text(_storeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('Documents'),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.primaryTeal),
            title: const Text('Mes Documents'),
            subtitle: const Text('Gérer tous vos documents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/documents'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primaryTeal),
            title: const Text('Templates'),
            subtitle: const Text('Modèles de documents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/templates'),
          ),
          const Divider(),
          _buildSectionHeader('Abonnement'),
          ListTile(
            leading: const Icon(Icons.card_membership, color: AppColors.primaryAmber),
            title: const Text('Mon Abonnement'),
            subtitle: Text(_plan),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSubscriptionPopup(context),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on, color: AppColors.primaryAmber),
            title: const Text('Points'),
            subtitle: const Text('Achetez et gérez vos points'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPointsDialog(),
          ),
          const Divider(),
          _buildSectionHeader("Besoin d'aide"),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primaryTeal),
            title: const Text('Appelez-nous'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _callSupport,
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
            title: const Text('Contactez-nous via WhatsApp'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openWhatsAppSupport,
          ),
          const Divider(),
          _buildSectionHeader('À propos'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryRed, side: const BorderSide(color: AppColors.primaryRed)),
              child: const Text('Se déconnecter'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
    );
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:+242050332359');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'effectuer l'appel"), backgroundColor: Colors.red));
    }
  }

  Future<void> _openWhatsAppSupport() async {
    final prefs = await SharedPreferences.getInstance();
    final boutiqueId = prefs.getString('boutique_id') ?? 'Non identifié';
    final message = Uri.encodeComponent("Bonjour, c'est $boutiqueId. J'ai besoin d'aide avec mon application Docs.");
    if (mounted) {
      await WhatsAppHelper.showChoice(context: context, message: message, groupType: 'support');
    }
  }

  Future<void> _showPointsDialog() async {
    final pointsBalance = await PointsService.getPointsBalance();
    if (!mounted) return;
    final codeController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mes Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solde: $pointsBalance pts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'PTS-XXXX-XXXX-XXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.isEmpty) return;
              final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
              if (boutiqueId == null) return;
              final error = await PointsService.validatePointsVoucher(code, boutiqueId);
              if (error != null) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                return;
              }
              final points = PointsService.extractPointsAmount(code);
              await PointsService.addPoints(points);
              await PointsService.markCodeUsed(code);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$points points crédités !'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubscriptionPopup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresStr = prefs.getString('subscription_expires');
    final plan = prefs.getString('subscription_plan') ?? 'BASIC';
    final expiryDate = expiresStr != null ? DateTime.parse(expiresStr) : DateTime.now().add(const Duration(days: 30));
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

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
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle),
                child: const Icon(Icons.card_membership, color: AppColors.primaryAmber, size: 32)),
            const SizedBox(height: 16),
            const Text('Mon Abonnement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(plan, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isExpired ? const Color(0xFFFFEBEE) : daysLeft > 7 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpired ? 'Expiré' : '$daysLeft jours restants',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: isExpired ? const Color(0xFFC62828) : daysLeft > 7 ? const Color(0xFF388E3C) : const Color(0xFFE65100)),
              ),
            ),
            if (!isExpired) ...[
              const SizedBox(height: 8),
              Text('Expire le ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _openWhatsAppForSubscription(); },
                icon: const Icon(Icons.chat, size: 20),
                label: const Text('Payer via WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsAppForSubscription() async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    final idText = boutiqueId != null ? ' Mon ID boutique: $boutiqueId' : '';
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent('Bonjour, je souhaite $action Yabisso Docs.$idText');
    if (mounted) {
      await WhatsAppHelper.showChoice(context: context, message: message, groupType: 'subscription');
    }
  }
}
