import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF6F00);
  static const Color _bg = Color(0xFFFCF9F8);

  Vendor? _selectedVendor;
  String _pin = '';
  bool _showPinEntry = false;
  bool _pinError = false;
  bool _isFirstTime = false;
  String _confirmPin = '';
  late AnimationController _shakeController;
  bool _checkingSubscription = true;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    if (mounted) {
      setState(() => _checkingSubscription = false);
      if (!hasSub) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSubscriptionRequiredDialog());
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primaryRed),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Abonnement requis',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous devez souscrire à un abonnement pour accéder à Yabisso Forms.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.vpn_key, size: 18, color: AppColors.primaryOrange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Entrez votre code',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Code OFF (abonnement) ou PTS (points)',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Veuillez entrer un code'), backgroundColor: Colors.orange),
                                );
                                return;
                              }
                              setDialogState(() => validating = true);
                              final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
                              if (boutiqueId == null) {
                                setDialogState(() => validating = false);
                                return;
                              }

                              if (code.startsWith('OFF-')) {
                                final error = await OfflineVoucherService.validateOfflineVoucher(code, boutiqueId);
                                if (error != null) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                                    );
                                  }
                                  return;
                                }
                                final plan = OfflineVoucherService.extractPlanFromCode(code) ?? 'BASIC';
                                final limit = OfflineVoucherService.getMaxFormsForPlan(plan);
                                await OfflineVoucherService.markCodeUsed(code);
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('has_subscription', true);
                                final expires = DateTime.now().add(const Duration(days: 30));
                                await prefs.setString('subscription_expires', expires.toIso8601String());
                                await prefs.setString('subscription_plan', plan);
                                if (limit != null) {
                                  await prefs.setInt('max_forms', limit);
                                } else {
                                  await prefs.remove('max_forms');
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Abonnement $plan activé avec succès !'), backgroundColor: Colors.green),
                                  );
                                }
                              } else if (code.startsWith('PTS-')) {
                                final error = await PointsService.validatePointsVoucher(code, boutiqueId);
                                if (error != null) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                                    );
                                  }
                                  return;
                                }
                                final points = PointsService.extractPointsAmount(code);
                                if (points <= 0) {
                                  setDialogState(() => validating = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text('Code invalide'), backgroundColor: Colors.red),
                                    );
                                  }
                                  return;
                                }
                                await PointsService.addPoints(points);
                                await PointsService.markCodeUsed(code);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$points points crédités !'), backgroundColor: Colors.green),
                                  );
                                }
                              } else {
                                setDialogState(() => validating = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Code invalide. Utilisez OFF-XXXX-XXXX ou PTS-XXXX-XXXX-XXXX'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openWhatsAppForSubscription();
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPointsPaymentDialog();
                      },
                      icon: const Icon(Icons.monetization_on, size: 20),
                      label: const Text('Payer avec points', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _callAdmin();
                      },
                      icon: const Icon(Icons.phone, size: 20),
                      label: const Text('Nous appeler', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(const ClipboardData(text: '242050332359'));
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Numéro copié !'), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                    child: SelectableText(
                      '242050332359',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
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

  void _callAdmin() {
    final uri = Uri.parse('tel:242050332359');
    try {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'effectuer l\'appel'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openWhatsAppForSubscription() {
    _showPlanSelectionDialog();
  }

  void _showPlanSelectionDialog() {
    if (!mounted) return;
    const planPrices = {
      'MICRO': 3500,
      'BASIC': 5000,
      'PREMIUM': 8000,
      'UNLIMITED': 10000,
    };
    const planDisplayNames = {
      'MICRO': 'Micro',
      'BASIC': 'Basique',
      'PREMIUM': 'Premium',
      'UNLIMITED': 'Illimité',
    };
    const planIcons = {
      'MICRO': Icons.store,
      'BASIC': Icons.storefront,
      'PREMIUM': Icons.emoji_events,
      'UNLIMITED': Icons.all_inclusive,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choisissez votre formule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ...planPrices.entries.map((entry) {
              final plan = entry.key;
              final price = entry.value;
              final displayName = planDisplayNames[plan] ?? plan;
              final icon = planIcons[plan] ?? Icons.star;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openWhatsAppWithPlan(plan, displayName);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 22, color: AppColors.textDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(displayName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark)),
                        ),
                        Text('${price.toString()} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsAppWithPlan(String plan, String planName) async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    final idText = boutiqueId != null ? ' Mon ID boutique: $boutiqueId' : '';
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent(
        'Bonjour, je souhaite $action Yabisso Forms $planName.$idText');
    if (mounted) {
      await WhatsAppHelper.showChoice(
        context: context,
        message: message,
        groupType: 'subscription',
      );
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: const Icon(Icons.monetization_on, color: Color(0xFFF5A623), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Choisissez votre plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Solde: $pointsBalance pts',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
                    onPressed: canAfford
                        ? () {
                            Navigator.pop(ctx);
                            _activateWithPoints(plan, price);
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: canAfford ? const Color(0xFFF5A623) : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: canAfford ? AppColors.textDark : Colors.grey)),
                        Text('$price pts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: canAfford ? const Color(0xFFF5A623) : Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateWithPoints(String plan, int price) async {
    final deducted = await PointsService.deductPoints(price);
    if (!deducted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Points insuffisants'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_subscription', true);
    final now = DateTime.now();
    final expires = now.add(const Duration(days: 30));
    await prefs.setString('subscription_expires', expires.toIso8601String());
    await prefs.setString('subscription_plan', plan);
    final limit = PointsService.planLimits[plan];
    if (limit != null) await prefs.setInt('max_forms', limit);
    if (limit == null) await prefs.remove('max_forms');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abonnement $plan activé ! $price points utilisés.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSubscription) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: (!_showPinEntry)
          ? FloatingActionButton.extended(
              onPressed: () => _showAddVendorDialog(),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          const Text('Yabisso Forms',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
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
          const Text('Qui êtes-vous ?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
                        const Text('Aucun utilisateur enregistré',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Ajoutez un utilisateur pour commencer',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddVendorDialog(),
                            icon: const Icon(Icons.person_add, size: 20),
                            label: const Text('Créer un utilisateur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Retour', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 500 ? 3 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
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
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFFFF6F00'));
    return GestureDetector(
      onTap: () => _selectVendor(vendor),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color,
              child: Text(
                vendor.initials ?? vendor.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(vendor.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                textAlign: TextAlign.center),
            const SizedBox(height: 3),
            Text(vendor.role,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: vendor.pinHash != null ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vendor.pinHash != null ? 'PIN configuré' : 'Première connexion',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: vendor.pinHash != null ? const Color(0xFF388E3C) : const Color(0xFFE65100)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinEntryView({Key? key}) {
    final vendor = _selectedVendor!;
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFFFF6F00'));
    final isFirstTime = vendor.pinHash == null;

    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() {
                _showPinEntry = false;
                _selectedVendor = null;
                _pin = '';
                _confirmPin = '';
                _pinError = false;
              }),
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
            CircleAvatar(
              radius: 36,
              backgroundColor: color,
              child: Text(
                vendor.initials ?? vendor.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(vendor.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(
              isFirstTime ? 'Créez votre PIN à 4 chiffres' : 'Entrez votre PIN',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (_isFirstTime && _confirmPin.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Confirmez votre PIN',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
            const SizedBox(height: 32),
            _buildPinDots(isFirstTime),
            if (_pinError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isFirstTime ? 'Les PIN ne correspondent pas' : 'PIN incorrect, réessayez',
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryRed),
                ),
              ),
            const SizedBox(height: 32),
            _buildNumpad(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(bool isFirstTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? _primary : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 72, height: 56);
                return SizedBox(
                  width: 72,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _onNumpadKey(key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: key == '⌫' ? Colors.grey[200] : Colors.white,
                      foregroundColor: key == '⌫' ? AppColors.primaryRed : AppColors.textDark,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: key == '⌫'
                        ? const Icon(Icons.backspace_outlined, size: 22)
                        : Text(key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _onNumpadKey(String key) {
    if (key == '⌫') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _pinError = false;
        });
      }
      return;
    }

    if (_pin.length >= 4) return;

    setState(() => _pin += key);

    if (_pin.length == 4) {
      _validatePin();
    }
  }

  Future<void> _validatePin() async {
    final vendor = _selectedVendor!;
    final isFirstTime = vendor.pinHash == null;

    if (isFirstTime) {
      if (_isFirstTime && _confirmPin.isNotEmpty) {
        if (_pin == _confirmPin) {
          final hash = BCrypt.hashpw(_pin, BCrypt.gensalt());
          final updatedVendor = Vendor(
            id: vendor.id,
            name: vendor.name,
            role: vendor.role,
            pinHash: hash,
            color: vendor.color,
            initials: vendor.initials,
            employeeId: vendor.employeeId,
            createdAt: vendor.createdAt,
          );
          await DatabaseHelper.instance.updateVendor(updatedVendor);
          ref.invalidate(vendorsProvider);
          _loginSuccess(vendor);
        } else {
          setState(() {
            _pinError = true;
            _pin = '';
            _confirmPin = '';
            _isFirstTime = false;
          });
        }
      } else {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isFirstTime = true;
        });
      }
    } else {
      final matches = BCrypt.checkpw(_pin, vendor.pinHash!);
      if (matches) {
        _loginSuccess(vendor);
      } else {
        setState(() {
          _pinError = true;
          _pin = '';
        });
        _shakeController.forward(from: 0);
      }
    }
  }

  void _loginSuccess(Vendor vendor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('current_vendor_id', vendor.id);
    await prefs.setString('current_vendor_name', vendor.name);
    ref.read(currentVendorProvider.notifier).state = vendor;
    if (mounted) context.go('/');
  }

  void _showAddVendorDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Vendeur');
    String selectedColor = '#FF6F00';
    final colors = ['#FF6F00', '#378ADD', '#1D9E75', '#E24B4A', '#7C3AED', '#F5A623'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Nouvel utilisateur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nom complet',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  hintText: 'Rôle (ex: Vendeur, Admin)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Couleur', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: colors.map((c) {
                  final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                  final isSelected = c == selectedColor;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final initials = name.split(' ').where((n) => n.isNotEmpty).map((n) => n[0].toUpperCase()).join('');
                final vendor = Vendor(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  role: roleController.text.trim().isEmpty ? 'Vendeur' : roleController.text.trim(),
                  color: selectedColor,
                  initials: initials,
                  createdAt: DateTime.now().toIso8601String(),
                );
                await DatabaseHelper.instance.insertVendor(vendor);
                ref.invalidate(vendorsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('Créer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _selectVendor(Vendor vendor) {
    setState(() {
      _selectedVendor = vendor;
      _showPinEntry = true;
      _pin = '';
      _confirmPin = '';
      _pinError = false;
      _isFirstTime = vendor.pinHash == null;
    });
  }
}
