import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../helpers/whatsapp_helper.dart';
import '../../services/offline_voucher_service.dart';
import '../../services/points_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _section('Général'),
          ListTile(
            leading: const Icon(Icons.dynamic_form, color: AppColors.primaryOrange),
            title: const Text('Mon Abonnement'),
            subtitle: const Text('Gérer votre abonnement'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSubscriptionPopup(context),
          ),
          const Divider(),
          _section('Support'),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primaryGreen),
            title: const Text('Appelez-nous'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(Uri.parse('tel:+242050332359'), mode: LaunchMode.externalApplication),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
            title: const Text('WhatsApp'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final bid = prefs.getString('boutique_id') ?? 'Inconnu';
              final msg = Uri.encodeComponent("Bonjour, c'est $bid. J'ai besoin d'aide avec Yabisso Forms.");
              if (context.mounted) await WhatsAppHelper.showChoice(context: context, message: msg);
            },
          ),
          const Divider(),
          _section('A propos'),
          const ListTile(leading: Icon(Icons.info_outline), title: Text('Version'), subtitle: Text('1.0.0')),
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('Yabisso Forms'),
            subtitle: Text('Formulaire dynamique pour marchands africains'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.primaryRed),
              ),
              child: const Text('Se deconnecter'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
    );
  }

  Future<void> _showSubscriptionPopup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresStr = prefs.getString('subscription_expires');
    final plan = prefs.getString('subscription_plan') ?? 'BASIC';
    final boutiqueId = prefs.getString('boutique_id');
    final expiryDate = expiresStr != null ? DateTime.parse(expiresStr) : DateTime.now().add(const Duration(days: 30));
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

    if (!context.mounted) return;
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
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: const Icon(Icons.dynamic_form, color: AppColors.primaryOrange, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Mon Abonnement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(plan, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            if (boutiqueId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: Text('ID: $boutiqueId',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isExpired
                    ? const Color(0xFFFFEBEE)
                    : daysLeft > 7
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpired ? 'Expire' : '$daysLeft jours restants',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isExpired
                      ? const Color(0xFFC62828)
                      : daysLeft > 7
                          ? const Color(0xFF388E3C)
                          : const Color(0xFFE65100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _sendWhatsAppSubscription(context);
                },
                icon: const Icon(Icons.chat, size: 20),
                label: const Text('Payer via WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppSubscription(BuildContext context) async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    final idText = boutiqueId != null ? ' Mon ID boutique: $boutiqueId' : '';
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent('Bonjour, je souhaite $action Yabisso Forms.$idText');
    if (context.mounted) {
      await WhatsAppHelper.showChoice(context: context, message: message, groupType: 'subscription');
    }
  }
}
