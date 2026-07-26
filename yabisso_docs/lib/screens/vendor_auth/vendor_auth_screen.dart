import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/vendor.dart';
import '../../services/offline_voucher_service.dart';
import '../../services/points_service.dart';
import '../../database/database_helper.dart';
import '../../helpers/whatsapp_helper.dart';

class VendorAuthScreen extends ConsumerStatefulWidget {
  const VendorAuthScreen({super.key});

  @override
  ConsumerState<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen> {
  static const Color _primary = Color(0xFF00897B);
  static const Color _bg = Color(0xFFF7F8FA);

  Vendor? _selectedVendor;
  String _pin = '';
  bool _showPinEntry = false;
  bool _pinError = false;
  bool _isFirstTime = false;
  String _confirmPin = '';
  bool _checkingSubscription = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    if (mounted) {
      setState(() { _checkingSubscription = false; });
      if (!hasSub) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSubscriptionRequiredDialog());
      }
    }
  }

  void _showSubscriptionRequiredDialog() {
    if (!mounted) return;
    final codeController = TextEditingController();
    bool validating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primaryRed),
                  ),
                  const SizedBox(height: 20),
                  const Text('Abonnement requis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text('Vous devez souscrire à un abonnement pour accéder à Yabisso Docs.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                      children: [
                        Row(children: [
                          const Icon(Icons.vpn_key, size: 18, color: AppColors.primaryTeal),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Entrez votre code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                        ]),
                        const SizedBox(height: 4),
                        Text('Code OFF (abonnement) ou PTS (points)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 10),
                        TextField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'OFF-XXXX-XXXX ou PTS-XXXX-XXXX-XXXX',
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
                            onPressed: validating ? null : () async {
                              final code = codeController.text.trim().toUpperCase();
                              if (code.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Veuillez entrer un code'), backgroundColor: Colors.orange));
                                return;
                              }
                              setDialogState(() => validating = true);
                              final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
                              if (boutiqueId == null) { setDialogState(() => validating = false); return; }
                              if (code.startsWith('OFF-')) {
                                final error = await OfflineVoucherService.validateOfflineVoucher(code, boutiqueId);
                                if (error != null) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                                  return;
                                }
                                final plan = OfflineVoucherService.extractPlanFromCode(code) ?? 'BASIC';
                                await OfflineVoucherService.markCodeUsed(code);
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('has_subscription', true);
                                final expires = DateTime.now().add(const Duration(days: 30));
                                await prefs.setString('subscription_expires', expires.toIso8601String());
                                await prefs.setString('subscription_plan', plan);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abonnement $plan activé avec succès !'), backgroundColor: Colors.green));
                              } else if (code.startsWith('PTS-')) {
                                final error = await PointsService.validatePointsVoucher(code, boutiqueId);
                                if (error != null) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                                  return;
                                }
                                final points = PointsService.extractPointsAmount(code);
                                if (points <= 0) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Code invalide'), backgroundColor: Colors.red));
                                  return;
                                }
                                await PointsService.addPoints(points);
                                await PointsService.markCodeUsed(code);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$points points crédités !'), backgroundColor: Colors.green));
                                  Navigator.pop(context);
                                  _showPointsPaymentDialog();
                                }
                              } else {
                                setDialogState(() => validating = false);
                                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Code invalide. Utilisez OFF-XXXX-XXXX ou PTS-XXXX-XXXX-XXXX'), backgroundColor: Colors.red));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: validating
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Valider le code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('— ou —', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _openWhatsAppForSubscription(); },
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Payer via WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _showPointsPaymentDialog(); },
                      icon: const Icon(Icons.monetization_on, size: 20),
                      label: const Text('Payer avec points', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAmber, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openWhatsAppForSubscription() => _showPlanSelectionDialog();

  void _showPlanSelectionDialog() {
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Choisissez votre formule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildPlanOption(ctx, 'Micro', '10 documents max', Icons.description_outlined, const Color(0xFFF5A623)),
            _buildPlanOption(ctx, 'Basique', '25 documents max', Icons.description, AppColors.primaryBlue),
            _buildPlanOption(ctx, 'Premium', '50 documents max', Icons.diamond_outlined, AppColors.primaryTeal),
            _buildPlanOption(ctx, 'Illimité', 'Documents illimités', Icons.all_inclusive, const Color(0xFF7C3AED)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(BuildContext ctx, String plan, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () { Navigator.pop(ctx); _openWhatsAppWithPlan(plan); },
          icon: Icon(icon, color: color, size: 22),
          label: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark)),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ]),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsAppWithPlan(String plan) async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    final idText = boutiqueId != null ? ' Mon ID boutique: $boutiqueId' : '';
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent('Bonjour, je souhaite $action Yabisso Docs $plan.$idText');
    if (mounted) {
      await WhatsAppHelper.showChoice(context: context, message: message, groupType: 'subscription');
    }
  }

  Future<void> _showPointsPaymentDialog() async {
    final pointsBalance = await PointsService.getPointsBalance();
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Choisissez votre plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Solde: $pointsBalance pts', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            ...PointsService.planPrices.entries.map((entry) {
              final plan = entry.key;
              final price = entry.value;
              final label = PointsService.planLabels[plan] ?? plan;
              final canAfford = pointsBalance >= price;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: canAfford ? () { Navigator.pop(ctx); _activateWithPoints(plan, price); } : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: canAfford ? AppColors.primaryAmber : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: canAfford ? AppColors.textDark : Colors.grey)),
                      Text('$price pts', style: TextStyle(fontWeight: FontWeight.bold, color: canAfford ? AppColors.primaryAmber : Colors.grey)),
                    ]),
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

  Future<void> _activateWithPoints(String plan, int price) async {
    final deducted = await PointsService.deductPoints(price);
    if (!deducted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Points insuffisants'), backgroundColor: Colors.red));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_subscription', true);
    final expires = DateTime.now().add(const Duration(days: 30));
    await prefs.setString('subscription_expires', expires.toIso8601String());
    await prefs.setString('subscription_plan', plan);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abonnement $plan activé ! $price points utilisés.'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSubscription) {
      return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator(color: _primary)));
    }
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: (!_showPinEntry)
          ? FloatingActionButton.extended(
              onPressed: _showAddVendorDialog,
              backgroundColor: _primary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _showPinEntry
                    ? _buildPinEntryView(key: const ValueKey('pin'))
                    : _buildVendorSelectionView(key: const ValueKey('vendor')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(color: _primary),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/')),
          const SizedBox(width: 8),
          const Text('Yabisso Docs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildVendorSelectionView({Key? key}) {
    final vendorsAsync = ref.watch(vendorsProvider);
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('Qui êtes-vous ?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Sélectionnez votre profil', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Expanded(
            child: vendorsAsync.when(
              data: (vendors) {
                if (vendors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('Aucun vendeur enregistré', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Ajoutez un vendeur pour commencer', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _showAddVendorDialog,
                            icon: const Icon(Icons.person_add, size: 20),
                            label: const Text('Créer un vendeur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width > 500 ? 3 : 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15),
                  itemCount: vendors.length,
                  itemBuilder: (context, index) => _buildVendorCard(vendors[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF00897B'));
    return GestureDetector(
      onTap: () => _selectVendor(vendor),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color,
              child: Text(vendor.initials ?? vendor.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Text(vendor.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 3),
            Text(vendor.role, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: vendor.pinHash != null ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vendor.pinHash != null ? 'PIN configuré' : 'Première connexion',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: vendor.pinHash != null ? const Color(0xFF388E3C) : const Color(0xFFE65100)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinEntryView({Key? key}) {
    final vendor = _selectedVendor!;
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF00897B'));
    final isFirstTime = vendor.pinHash == null;

    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() { _showPinEntry = false; _selectedVendor = null; _pin = ''; _confirmPin = ''; _pinError = false; }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Changer de profil', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(radius: 36, backgroundColor: color,
                child: Text(vendor.initials ?? vendor.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
            const SizedBox(height: 14),
            Text(vendor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(isFirstTime ? 'Créez votre PIN à 4 chiffres' : 'Entrez votre PIN', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 32),
            _buildPinDots(isFirstTime),
            if (_pinError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(isFirstTime ? 'Les PIN ne correspondent pas' : 'PIN incorrect, réessayez', style: const TextStyle(fontSize: 12, color: AppColors.primaryRed)),
              ),
            const SizedBox(height: 32),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(bool isFirstTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = _pin.length > i;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? _primary : Colors.grey[300],
            border: Border.all(color: _pinError ? AppColors.primaryRed : Colors.transparent, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((n) => _buildNumpadButton(n)).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70),
            _buildNumpadButton(0),
            GestureDetector(
              onTap: _onBackspace,
              child: Container(width: 70, height: 50, alignment: Alignment.center,
                  child: const Icon(Icons.backspace_outlined, color: Colors.grey, size: 28)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadButton(int n) {
    return GestureDetector(
      onTap: () => _onNumpadTap(n),
      child: Container(
        width: 70, height: 50,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text('$n', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ),
    );
  }

  void _onNumpadTap(int n) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += '$n';
      _pinError = false;
    });
    if (_pin.length == 4) _validatePin();
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() { _pin = _pin.substring(0, _pin.length - 1); _pinError = false; });
    }
  }

  Future<void> _validatePin() async {
    final vendor = _selectedVendor!;
    final isFirstTime = vendor.pinHash == null;

    if (isFirstTime) {
      if (_confirmPin.isEmpty) {
        setState(() { _confirmPin = _pin; _pin = ''; });
        return;
      }
      if (_pin != _confirmPin) {
        setState(() { _pinError = true; _pin = ''; _confirmPin = ''; });
        return;
      }
      final hash = BCrypt.hashpw(_pin, BCrypt.gensalt());
      final updated = Vendor(id: vendor.id, name: vendor.name, role: vendor.role, pinHash: hash, color: vendor.color, initials: vendor.initials, employeeId: vendor.employeeId, createdAt: vendor.createdAt);
      await DatabaseHelper.instance.updateVendor(updated);
      _loginWithVendor(updated);
    } else {
      final matches = BCrypt.checkpw(_pin, vendor.pinHash!);
      if (matches) {
        _loginWithVendor(vendor);
      } else {
        setState(() { _pinError = true; _pin = ''; });
      }
    }
  }

  void _loginWithVendor(Vendor vendor) async {
    ref.read(currentVendorProvider.notifier).state = vendor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('has_subscription', true);
    if (mounted) context.go('/');
  }

  void _showAddVendorDialog() {
    final nameController = TextEditingController();
    String selectedRole = 'Vendeur';
    String selectedColor = '#00897B';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Nouveau vendeur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nom du vendeur',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Propriétaire', 'Vendeur', 'Gérant'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) { if (v != null) setSheetState(() => selectedRole = v); },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    final id = '${DateTime.now().millisecondsSinceEpoch}';
                    final initials = nameController.text.trim().split(' ').map((n) => n.isNotEmpty ? n[0].toUpperCase() : '').join('');
                    final vendor = Vendor(id: id, name: nameController.text.trim(), role: selectedRole, color: selectedColor, initials: initials, createdAt: DateTime.now().toIso8601String());
                    await DatabaseHelper.instance.insertVendor(vendor);
                    ref.invalidate(vendorsProvider);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
