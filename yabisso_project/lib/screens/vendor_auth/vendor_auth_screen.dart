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
import '../../services/currency_service.dart';
import '../../services/points_service.dart';
import '../../services/offline_voucher_service.dart';
import '../../helpers/whatsapp_helper.dart';

class VendorAuthScreen extends ConsumerStatefulWidget {
  const VendorAuthScreen({super.key});

  @override
  ConsumerState<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF00694C);
  static const Color _bg = Color(0xFFFCF9F8);
  static const Color _surface = Color(0xFFF0EDEC);
  static const Color _coral = Color(0xFFE24B4A);

  Vendor? _selectedVendor;
  String _pin = '';
  bool _showPinEntry = false;
  bool _pinError = false;
  bool _isFirstTime = false;
  String _confirmPin = '';
  late AnimationController _shakeController;
  bool _checkingSubscription = true;

  static const Map<String, int> _planCashPrices = {
    'MICRO': 3500,
    'BASIC': 5000,
    'PREMIUM': 8000,
    'UNLIMITED': 10000,
  };

  static const Map<String, String> _planDisplayNames = {
    'MICRO': 'Micro',
    'BASIC': 'Basique',
    'PREMIUM': 'Premium',
    'UNLIMITED': 'Illimité',
  };

  static const Map<String, String> _planBadges = {
    'BASIC': 'Populaire',
    'PREMIUM': 'Meilleur choix',
    'UNLIMITED': 'Premium',
  };

  static const Map<String, Color> _planBadgeColors = {
    'BASIC': Color(0xFF1D9E75),
    'PREMIUM': Color(0xFF7C3AED),
    'UNLIMITED': Color(0xFFF59E0B),
  };

  static const Map<String, IconData> _planIcons = {
    'MICRO': Icons.store,
    'BASIC': Icons.storefront,
    'PREMIUM': Icons.emoji_events,
    'UNLIMITED': Icons.all_inclusive,
  };

  static const Map<String, int?> _planLimits = {
    'MICRO': 10,
    'BASIC': 25,
    'PREMIUM': 50,
    'UNLIMITED': null,
  };

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
      setState(() {
        _checkingSubscription = false;
      });
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
                    'Vous devez souscrire à un abonnement pour accéder à l\'application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _BoutiqueInfoWidget(),
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
                            const Icon(Icons.vpn_key, size: 18, color: AppColors.primaryGreen),
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
                                final limit = OfflineVoucherService.getMaxProductsForPlan(plan);
                                await OfflineVoucherService.markCodeUsed(code);
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('has_subscription', true);
                                final expires = DateTime.now().add(const Duration(days: 30));
                                await prefs.setString('subscription_expires', expires.toIso8601String());
                                await prefs.remove('reminder_5d_shown');
                                await prefs.remove('reminder_1d_shown');
                                await prefs.setString('subscription_plan', plan);
                                if (limit != null) {
                                  await prefs.setInt('max_products', limit);
                                } else {
                                  await prefs.remove('max_products');
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
                                  Navigator.pop(context);
                                  _showPointsPaymentDialog();
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
                              backgroundColor: AppColors.primaryGreen,
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
                        backgroundColor: AppColors.primaryAmber,
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
                        backgroundColor: AppColors.primaryGreen,
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
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_membership, color: AppColors.primaryAmber, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Choisissez votre formule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ..._planCashPrices.entries.map((entry) {
              final plan = entry.key;
              final price = entry.value;
              final displayName = _planDisplayNames[plan] ?? plan;
              final badge = _planBadges[plan];
              final badgeColor = _planBadgeColors[plan];
              final icon = _planIcons[plan] ?? Icons.star;
              final isUnlimited = plan == 'UNLIMITED';
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
                      side: BorderSide(
                        color: badge != null ? (badgeColor ?? AppColors.primaryGreen) : Colors.grey[300]!,
                        width: badge != null ? 2 : 1,
                      ),
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
                                  Text(displayName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textDark)),
                                  if (badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeColor!.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(badge,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: badgeColor)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                isUnlimited ? 'Produits illimités' : '${_planLimits[plan]} produits',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        Text(fmtPrice(price.toDouble()),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: badge != null ? badgeColor : AppColors.textDark)),
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
        'Bonjour, je souhaite $action Yabisso Project $planName.$idText');
    if (mounted) {
      await WhatsAppHelper.showChoice(
        context: context,
        message: message,
        groupType: 'subscription',
      );
    }
    if (mounted) _showOfflineVoucherEntryDialog();
  }

  Future<void> _showOfflineVoucherEntryDialog() async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    if (!mounted || boutiqueId == null) return;

    final codeController = TextEditingController();
    bool validating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vpn_key, size: 36, color: Color(0xFF1D9E75)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Activer votre abonnement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'L\'administrateur vous a envoyé un code OFF par WhatsApp. Collez-le ici pour activer votre abonnement.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'OFF-XXXX-XXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16, letterSpacing: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validating
                      ? null
                      : () async {
                          setDialogState(() => validating = true);
                          final code = codeController.text.trim();
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
                          final limit = OfflineVoucherService.getMaxProductsForPlan(plan);

                          await OfflineVoucherService.markCodeUsed(code);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('has_subscription', true);
                          final now = DateTime.now();
                          final expires = now.add(const Duration(days: 30));
                          await prefs.setString('subscription_expires', expires.toIso8601String());
                          await prefs.remove('reminder_5d_shown');
                          await prefs.remove('reminder_1d_shown');
                          await prefs.setString('subscription_plan', plan);
                          if (limit != null) {
                            await prefs.setInt('max_products', limit);
                          } else {
                            await prefs.remove('max_products');
                          }

                           if (ctx.mounted) Navigator.pop(ctx);
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Abonnement $plan activé avec succès !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: validating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Activer mon abonnement', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (mounted) _showSubscriptionRequiredDialog();
                },
                child: const Text('Retour', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monetization_on,
                  color: AppColors.primaryAmber, size: 32),
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
                        color: canAfford
                            ? AppColors.primaryAmber
                            : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: canAfford
                                    ? AppColors.textDark
                                    : Colors.grey)),
                        Text('$price pts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: canAfford
                                    ? AppColors.primaryAmber
                                    : Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showPointsRechargementDialog();
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Recharger mes points',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _showSubscriptionRequiredDialog());
              },
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPointsRechargementDialog() async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    if (!mounted || boutiqueId == null) return;

    final codeController = TextEditingController();
    bool validating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on, size: 36, color: AppColors.primaryAmber),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recharger mes points',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez le code PTS que l\'administrateur vous a envoyé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'PTS-XXXX-XXXX-XXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14, letterSpacing: 1),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validating
                      ? null
                      : () async {
                          setDialogState(() => validating = true);
                          final code = codeController.text.trim().toUpperCase();
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
                              SnackBar(
                                content: Text('$points points crédités !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _showPointsPaymentDialog();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: validating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Valider le code', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (mounted) _showSubscriptionRequiredDialog();
                },
                child: const Text('Retour', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _activateWithPoints(String plan, int price) async {
    final deducted = await PointsService.deductPoints(price);
    if (!deducted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Points insuffisants'),
            backgroundColor: Colors.red,
          ),
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
    if (limit != null) await prefs.setInt('max_products', limit);
    if (limit == null) await prefs.remove('max_products');

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
          const Text('Yabisso Project',
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
                        const Text('Aucun vendeur enregistré',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Ajoutez un vendeur pour commencer',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddVendorDialog(),
                            icon: const Icon(Icons.person_add, size: 20),
                            label: const Text('Créer un vendeur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF00694C'));
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
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF00694C'));
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
                  style: TextStyle(fontSize: 12, color: _coral),
                ),
              ),
            const SizedBox(height: 32),
            _buildNumpad(),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() {
                _showPinEntry = false;
                _selectedVendor = null;
                _pin = '';
                _confirmPin = '';
                _pinError = false;
              }),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('ANNULER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: _coral),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(bool isFirstTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: filled ? 18 : 14,
          height: filled ? 18 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? (_pinError ? _coral : _primary) : _surface,
            border: Border.all(color: filled ? (_pinError ? _coral : _primary) : Colors.grey[350]!, width: 2),
          ),
          child: Center(
            child: filled
                ? Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['cancel', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isCancel = key == 'cancel';
              final isBackspace = key == 'backspace';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _onKeyPress(key),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isCancel || isBackspace) ? const Color(0xFFFCF0F0) : const Color(0xFFF0EDEC),
                    ),
                    child: Center(
                      child: isCancel
                          ? const Icon(Icons.close_rounded, size: 22, color: Color(0xFFE24B4A))
                          : isBackspace
                              ? const Icon(Icons.backspace_outlined, size: 22, color: Color(0xFF555555))
                              : Text(key,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF111111))),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  void _selectVendor(Vendor vendor) {
    setState(() {
      _selectedVendor = vendor;
      _pin = '';
      _confirmPin = '';
      _showPinEntry = true;
      _pinError = false;
      _isFirstTime = vendor.pinHash == null;
    });
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        _pinError = false;
      } else if (key == 'cancel') {
        _showPinEntry = false;
        _selectedVendor = null;
        _pin = '';
        _confirmPin = '';
        _pinError = false;
        return;
      } else {
        if (_pin.length < 4) _pin += key;
        if (_pin.length == 4) _validatePin();
      }
    });
  }

  void _validatePin() async {
    final vendor = _selectedVendor!;
    final isFirstTime = vendor.pinHash == null;

    if (isFirstTime) {
      if (_confirmPin.isEmpty) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
        });
      } else {
        if (_pin == _confirmPin) {
            final updated = Vendor(
            id: vendor.id,
            name: vendor.name,
            role: vendor.role,
            pinHash: BCrypt.hashpw(_pin, BCrypt.gensalt()),
            color: vendor.color,
            initials: vendor.initials,
            employeeId: vendor.employeeId,
            createdAt: vendor.createdAt,
          );
          await ref.read(databaseProvider).updateVendor(updated);
          ref.invalidate(vendorsProvider);
          _login();
        } else {
          setState(() {
            _pinError = true;
            _pin = '';
            _confirmPin = '';
          });
          _shakeController.forward(from: 0);
        }
      }
    } else {
      final pinHash = vendor.pinHash;
      final isValid = pinHash != null && BCrypt.checkpw(_pin, pinHash);
      if (isValid) {
        _login();
      } else {
        setState(() {
          _pinError = true;
          _pin = '';
        });
        _shakeController.forward(from: 0);
      }
    }
  }

  void _login() {
    ref.read(currentVendorProvider.notifier).state = _selectedVendor;
    context.go('/');
  }

  void _showAddVendorDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Vendeur');
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    String selectedColor = '#00694C';

    final colors = [
      '#00694C', '#E24B4A', '#378ADD', '#F5A623', '#9B59B6',
      '#1ABC9C', '#E67E22', '#34495E',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nouveau vendeur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Nom du vendeur',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: _primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    hintText: 'Rôle (ex: Vendeur, Gérant)',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: _primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'PIN à 4 chiffres',
                    counterText: '',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _primary),
                    ),
                  ),
                ),
                TextField(
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirmer le PIN',
                    counterText: '',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Couleur', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final color = Color(int.parse('0xFF${c.replaceAll('#', '')}'));
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (nameController.text.trim().isEmpty) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Veuillez entrer un nom'), backgroundColor: Colors.orange),
                      );
                    }
                    return;
                  }

                  final name = nameController.text.trim();
                  final initials = name.split(' ').map((w) => w[0]).take(2).join().toUpperCase();
                  final pin = pinController.text.trim();
                  final confirmPin = confirmPinController.text.trim();

                  if (pin.isNotEmpty && pin.length != 4) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Le PIN doit contenir 4 chiffres'), backgroundColor: Colors.orange),
                      );
                    }
                    return;
                  }
                  if (pin.isNotEmpty && pin != confirmPin) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Les PIN ne correspondent pas'), backgroundColor: Colors.red),
                      );
                    }
                    return;
                  }

                  final newVendor = Vendor(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    role: roleController.text.trim().isNotEmpty ? roleController.text.trim() : 'Vendeur',
                    pinHash: pin.isNotEmpty ? BCrypt.hashpw(pin, BCrypt.gensalt()) : null,
                    color: selectedColor,
                    initials: initials,
                    createdAt: DateTime.now().toIso8601String(),
                  );

                  await ref.read(databaseProvider).insertVendor(newVendor);
                  ref.invalidate(vendorsProvider);

                  if (ctx.mounted) Navigator.pop(ctx);

                  if (mounted) {
                    final vendorsList = await ref.read(databaseProvider).getAllVendors();
                    if (vendorsList.length == 1) {
                      ref.read(currentVendorProvider.notifier).state = newVendor;
                      context.go('/');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$name ajouté avec succès'), backgroundColor: Colors.green),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de l\'ajout: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutiqueInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _loadBoutiqueInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!;
        final boutiqueId = data['boutique_id'];
        final plan = data['subscription_plan'];
        final expiresStr = data['subscription_expires'];
        final storePhone = data['store_phone'];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E6E4)),
          ),
          child: Column(
            children: [
              if (boutiqueId != null && boutiqueId.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.store, size: 14, color: Color(0xFF00694C)),
                    const SizedBox(width: 6),
                    const Text('ID Boutique: ',
                        style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                    Expanded(
                      child: SelectableText(boutiqueId,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (storePhone != null && storePhone.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Color(0xFF00694C)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SelectableText(storePhone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (plan != null) ...[
                Row(
                  children: [
                    const Icon(Icons.card_membership, size: 14, color: Color(0xFFF5A623)),
                    const SizedBox(width: 6),
                    Text('Plan: $plan',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (expiresStr != null) ...[
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF999999)),
                    const SizedBox(width: 6),
                    Text('Expire: ${expiresStr.substring(0, 10)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String?>> _loadBoutiqueInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'boutique_id': prefs.getString('boutique_id'),
      'subscription_plan': prefs.getString('subscription_plan'),
      'subscription_expires': prefs.getString('subscription_expires'),
      'store_phone': prefs.getString('store_phone'),
    };
  }
}
