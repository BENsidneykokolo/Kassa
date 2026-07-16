import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/vendor.dart';
import '../../providers/providers.dart';
import '../../helpers/whatsapp_helper.dart';

class VendorAuthScreen extends ConsumerStatefulWidget {
  const VendorAuthScreen({super.key});

  @override
  ConsumerState<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isCreatingPin = false;
  Vendor? _existingLeader;

  @override
  void initState() {
    super.initState();
    _checkExistingLeader();
  }

  Future<void> _checkExistingLeader() async {
    final db = DatabaseHelper.instance;
    final vendors = await db.getAllVendors();
    final leaders = vendors.where((v) => v.role == 'pastor' || v.role == 'leader').toList();
    if (leaders.isNotEmpty && mounted) {
      setState(() => _existingLeader = leaders.first);
    } else if (mounted) {
      setState(() => _isCreatingPin = true);
    }
  }

  Future<void> _createPin() async {
    if (_nameController.text.isEmpty || _pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom requis et PIN minimum 4 chiffres')),
      );
      return;
    }

    final db = DatabaseHelper.instance;
    final vendor = Vendor(
      id: const Uuid().v4(),
      name: _nameController.text,
      role: 'pastor',
      pinHash: _pinController.text,
      color: '#040C1C',
      initials: _nameController.text.split(' ').map((w) => w[0]).take(2).join().toUpperCase(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await db.insertVendor(vendor);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN créé avec succès'), backgroundColor: Colors.green),
      );
      context.go('/');
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) return;

    if (_pinController.text == _existingLeader?.pinHash) {
      ref.read(currentVendorProvider.notifier).state = _existingLeader;
      if (mounted) context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrect'), backgroundColor: Colors.red),
      );
      _pinController.clear();
    }
  }

  void _showSubscriptionDialog() {
    final plans = {
      'micro': {'name': 'Micro', 'members': '10 membres', 'price': 'Gratuit'},
      'basic': {'name': 'Basic', 'members': '25 membres', 'price': '5 000 FC/mois'},
      'premium': {'name': 'Premium', 'members': '50 membres', 'price': '10 000 FC/mois'},
      'unlimited': {'name': 'Illimité', 'members': 'Illimité', 'price': '25 000 FC/mois'},
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir un forfait'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: plans.entries.map((entry) => ListTile(
            title: Text(entry.value['name']!),
            subtitle: Text('${entry.value['members']} - ${entry.value['price']}'),
            leading: const Icon(Icons.star, color: AppColors.secondary),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Forfait ${entry.value['name']} sélectionné')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _sendWhatsAppMessage() async {
    final db = DatabaseHelper.instance;
    final churchId = await db.getSetting('church_id') ?? 'N/A';
    final churchName = await db.getSetting('church_name') ?? 'Mon Eglise';
    WhatsAppHelper.openChat(
      message: 'Bonjour Yabisso,\n\nJe souhaite activer mon abonnement.\n\nÉglise: $churchName\nID: $churchId',
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.shield, size: 56, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text(
                    _isCreatingPin ? 'Créer votre PIN' : 'Authentification',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCreatingPin
                        ? 'Définissez un PIN pour accéder à l\'application'
                        : 'Entrez votre PIN pour continuer',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  if (_isCreatingPin) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Votre nom',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      prefixIcon: Icon(Icons.lock),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreatingPin ? _createPin : _verifyPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isCreatingPin ? 'Créer le PIN' : 'Connexion',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _showSubscriptionDialog,
                    child: const Text('Gérer l\'abonnement'),
                  ),
                  TextButton(
                    onPressed: _sendWhatsAppMessage,
                    child: const Text('Support WhatsApp'),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
