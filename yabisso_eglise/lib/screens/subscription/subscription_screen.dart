import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../helpers/whatsapp_helper.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _churchNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = true;
  String _selectedPlan = 'basic';

  final Map<String, Map<String, dynamic>> _plans = {
    'micro': {'name': 'Micro', 'members': 10, 'price': 'Gratuit'},
    'basic': {'name': 'Basic', 'members': 25, 'price': '5 000 FC/mois'},
    'premium': {'name': 'Premium', 'members': 50, 'price': '10 000 FC/mois'},
    'unlimited': {'name': 'Illimité', 'members': -1, 'price': '25 000 FC/mois'},
  };

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isConfigured = prefs.getBool('church_configured') ?? false;
    if (isConfigured && mounted) {
      context.go('/');
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _churchNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChurch() async {
    if (_churchNameController.text.isEmpty || _ownerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final db = DatabaseHelper.instance;
    await db.setSetting('church_name', _churchNameController.text);
    await db.setSetting('owner_name', _ownerNameController.text);
    await db.setSetting('owner_phone', _phoneController.text);
    await db.setSetting('subscription_plan', _selectedPlan);
    await db.setSetting('church_id', 'YCE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('church_configured', true);
    await prefs.setString('church_name', _churchNameController.text);

    if (mounted) {
      context.go('/');
    }
  }

  void _validateVoucher() {
    final voucherController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider un voucher'),
        content: TextField(
          controller: voucherController,
          decoration: const InputDecoration(
            hintText: 'Entrez le code (OFF-XXXX ou PTS-XXXX)',
            prefixIcon: Icon(Icons.card_giftcard),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = voucherController.text.toUpperCase();
              if (code.startsWith('OFF-') || code.startsWith('PTS-')) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voucher validé avec succès!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code invalide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.church, size: 64, color: AppColors.secondary),
              const SizedBox(height: 16),
              const Text(
                'Yabisso Eglise',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestion d\'église intelligent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration initiale',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _churchNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'église *',
                        prefixIcon: Icon(Icons.church),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du pasteur/propriétaire *',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choisir un forfait',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ..._plans.entries.map((entry) => RadioListTile<String>(
                      value: entry.key,
                      groupValue: _selectedPlan,
                      onChanged: (v) => setState(() => _selectedPlan = v!),
                      activeColor: AppColors.secondary,
                      title: Text(entry.value['name'] as String),
                      subtitle: Text(
                        '${entry.value['members'] == -1 ? 'Illimité' : '${entry.value['members']} membres'} - ${entry.value['price']}',
                      ),
                    )),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChurch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _validateVoucher,
                      child: const Text('J\'ai un voucher'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => WhatsAppHelper.showChoice(
                  context,
                  message: 'Bonjour, je souhaite souscrire à Yabisso Eglise',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Text(
                      'Besoin d\'aide ? Contactez-nous',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
