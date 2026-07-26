import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _storeName = 'Mon Business';
  String _selectedLanguage = 'Français';

  static const Map<String, String> _languages = {
    'Français': 'Français',
    'English': 'English',
    'Lingala': 'Lingala',
  };

  static const Map<String, int> _planCashPrices = {
    'STARTER': 3000,
    'BUSINESS': 6000,
    'PRO': 10000,
    'UNLIMITED': 15000,
  };

  static const Map<String, String> _planDisplayNames = {
    'STARTER': 'Starter',
    'BUSINESS': 'Business',
    'PRO': 'Professionnel',
    'UNLIMITED': 'Illimité',
  };

  static const Map<String, String> _planBadges = {
    'BUSINESS': 'Populaire',
    'PRO': 'Meilleur choix',
    'UNLIMITED': 'Premium',
  };

  static const Map<String, Color> _planBadgeColors = {
    'BUSINESS': AppColors.primaryGreen,
    'PRO': AppColors.primaryPurple,
    'UNLIMITED': AppColors.primaryAmber,
  };

  static const Map<String, IconData> _planIcons = {
    'STARTER': Icons.rocket_launch,
    'BUSINESS': Icons.business_center,
    'PRO': Icons.emoji_events,
    'UNLIMITED': Icons.all_inclusive,
  };

  static const Map<String, String> _planDescriptions = {
    'STARTER': '10 conversations/jour, insights basiques',
    'BUSINESS': '50 conversations/jour, tous les insights',
    'PRO': 'Illimité, priorite support, rapports IA',
    'UNLIMITED': 'Tout illimité + fonctionnalites avancees',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeName = prefs.getString('store_name') ?? 'Mon Business';
      _selectedLanguage = prefs.getString('language') ?? 'Français';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parametres'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Informations'),
          ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.store, color: AppColors.primaryPurple, size: 22)),
            title: const Text('Ma Boutique'),
            subtitle: Text(_storeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showStoreInfoDialog,
          ),
          ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryBlue.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.language, color: AppColors.primaryBlue, size: 22)),
            title: const Text('Langue'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
          const Divider(),
          _buildSectionHeader('Abonnement'),
          ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryAmber.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.card_membership, color: AppColors.primaryAmber, size: 22)),
            title: const Text('Mon Abonnement'),
            subtitle: const Text('Gerez votre formule'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSubscriptionSheet,
          ),
          const Divider(),
          _buildSectionHeader('Aide & Support'),
          ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryGreen.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.phone, color: AppColors.primaryGreen, size: 22)),
            title: const Text('Appelez-nous'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openUrl('tel:+242050332359'),
          ),
          ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF25D366).withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 22)),
            title: const Text('Contactez-nous via WhatsApp'),
            subtitle: const Text('+242 050 332 359'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openWhatsApp,
          ),
          const Divider(),
          _buildSectionHeader('A propos'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Conditions d\'utilisation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTerms,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialite'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacy,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
    );
  }

  void _showStoreInfoDialog() {
    final controller = TextEditingController(text: _storeName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nom de la boutique'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez le nom',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('store_name', controller.text);
              setState(() => _storeName = controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.key),
            subtitle: Text(entry.value),
            value: entry.value,
            groupValue: _selectedLanguage,
            activeColor: AppColors.primaryPurple,
            onChanged: (value) async {
              if (value != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', value);
                setState(() => _selectedLanguage = value);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showSubscriptionSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresStr = prefs.getString('subscription_expires');
    final plan = prefs.getString('subscription_plan') ?? 'STARTER';
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
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle), child: const Icon(Icons.card_membership, color: AppColors.primaryAmber, size: 32)),
            const SizedBox(height: 16),
            const Text('Mon Abonnement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_planDisplayNames[plan] ?? plan, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isExpired ? const Color(0xFFFFEBEE) : daysLeft > 7 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpired ? 'Expire' : '$daysLeft jours restants',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isExpired ? const Color(0xFFC62828) : daysLeft > 7 ? const Color(0xFF388E3C) : const Color(0xFFE65100),
                ),
              ),
            ),
            if (!isExpired) ...[
              const SizedBox(height: 8),
              Text('Expire le ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            const SizedBox(height: 16),

            // Code entry
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: _buildCodeEntry(),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showPlanSelectionSheet();
                },
                icon: const Icon(Icons.arrow_upward, size: 20),
                label: const Text('Modifier l\'abonnement', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryPurple, side: const BorderSide(color: AppColors.primaryPurple), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openWhatsAppSubscription();
                },
                icon: const Icon(Icons.chat, size: 20),
                label: const Text('Payer via WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openUrl('tel:+242050332359'),
                icon: const Icon(Icons.phone, size: 20),
                label: const Text('Nous appeler', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeEntry() {
    return _CodeEntryWidget();
  }

  void _showPlanSelectionSheet() {
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
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle), child: const Icon(Icons.card_membership, color: AppColors.primaryAmber, size: 32)),
            const SizedBox(height: 16),
            const Text('Choisissez votre formule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ..._planCashPrices.entries.map((entry) {
              final planKey = entry.key;
              final price = entry.value;
              final displayName = _planDisplayNames[planKey] ?? planKey;
              final badge = _planBadges[planKey];
              final badgeColor = _planBadgeColors[planKey];
              final icon = _planIcons[planKey] ?? Icons.star;
              final description = _planDescriptions[planKey] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openWhatsAppWithPlan(planKey, displayName);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      side: BorderSide(color: badge != null ? (badgeColor ?? AppColors.primaryPurple) : Colors.grey[300]!, width: badge != null ? 2 : 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 22, color: badge != null ? badgeColor : AppColors.textDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(displayName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark)),
                                  if (badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: badgeColor!.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                                      child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Text('${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: badge != null ? badgeColor : AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final message = Uri.encodeComponent('Bonjour, j\'ai besoin d\'aide avec Yabisso IA.');
    final uri = Uri.parse('https://wa.me/242050332359?text=$message');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openWhatsAppSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('store_name') ?? 'Mon Business';
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent('Bonjour, je souhaite $action Yabisso IA pour $storeName.');
    final uri = Uri.parse('https://wa.me/242050332359?text=$message');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant Yabisso IA, vous acceptez les conditions suivantes :\n\n'
            '1. L\'application fournit des analyses et conseils bases sur vos donnees.\n'
            '2. Les recommandations IA ne remplacent pas un conseil professionnal.\n'
            '3. Vos donnees sont stockees localement sur votre appareil.\n'
            '4. L\'abonnement est requis pour acceder a toutes les fonctionnalites.\n'
            '5. Le support technique est disponible via WhatsApp.\n\n'
            'Version 1.0.0 - Yabisso IA',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Politique de confidentialite'),
        content: const SingleChildScrollView(
          child: Text(
            'Yabisso IA respecte votre vie privee :\n\n'
            '1. Toutes vos donnees restent sur votre appareil.\n'
            '2. Aucune donnee n\'est partagee avec des tiers.\n'
            '3. Les conversations IA sont traitees en local.\n'
            '4. Vos informations de boutique ne sont jamais exportees sans votre accord.\n'
            '5. Vous pouvez supprimer vos donnees a tout moment.\n\n'
            'Version 1.0.0 - Yabisso IA',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }
}

class _CodeEntryWidget extends StatefulWidget {
  @override
  State<_CodeEntryWidget> createState() => _CodeEntryWidgetState();
}

class _CodeEntryWidgetState extends State<_CodeEntryWidget> {
  final _controller = TextEditingController();
  bool _validating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.vpn_key, size: 18, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            const Expanded(child: Text('Entrez votre code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          ],
        ),
        const SizedBox(height: 4),
        Text('Code OFF (abonnement) ou PTS (points)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'OFF-XXXX-XXXX',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validating ? null : _validateCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _validating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Valider le code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Future<void> _validateCode() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un code'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() => _validating = true);

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    String? plan;
    if (code.startsWith('OFF-')) {
      plan = 'BUSINESS';
    } else if (code.startsWith('PTS-')) {
      final points = 500;
      final currentPoints = prefs.getInt('points') ?? 0;
      await prefs.setInt('points', currentPoints + points);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$points points credites !'), backgroundColor: Colors.green),
        );
      }
      setState(() => _validating = false);
      return;
    } else {
      setState(() => _validating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code invalide. Utilisez OFF-XXXX-XXXX ou PTS-XXXX-XXXX'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (plan != null) {
      await prefs.setBool('has_subscription', true);
      final expires = DateTime.now().add(const Duration(days: 30));
      await prefs.setString('subscription_expires', expires.toIso8601String());
      await prefs.setString('subscription_plan', plan);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abonnement $plan active avec succes !'), backgroundColor: Colors.green),
        );
      }
    }

    setState(() => _validating = false);
  }
}
