import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../services/offline_voucher_service.dart';
import '../../services/points_service.dart';
import '../../helpers/whatsapp_helper.dart';

class VendorAuthScreen extends StatefulWidget {
  const VendorAuthScreen({super.key});
  @override
  State<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends State<VendorAuthScreen> {
  bool _isLoading = true;
  bool _hasSubscription = false;
  String _selectedVendorPin = '';
  bool _isCreatingPin = false;
  bool _showNumpad = false;
  String _storeName = 'Mon Magasin';
  String _ownerName = 'Proprietaire';
  String? _boutiqueId;
  int? _selectedVendorId;
  String _enteredPin = '';
  int _pinStep = 0;
  String _tempPin = '';

  final _pinController = TextEditingController();
  final _voucherController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSubscription = prefs.getBool('has_subscription') ?? false;
    _storeName = prefs.getString('store_name') ?? 'Mon Magasin';
    _ownerName = prefs.getString('user_name') ?? 'Proprietaire';
    _boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    if (mounted) setState(() => _isLoading = false);
    if (!_hasSubscription && mounted) {
      _showSubscriptionRequiredDialog();
    }
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.primaryRed.withAlpha(25), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.lock, color: AppColors.primaryRed, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Abonnement requis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Activez votre abonnement pour acceder a Yabisso IA', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          _voucherCodeField(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _activateVoucherFromDialog,
              icon: const Icon(Icons.check_circle),
              label: const Text('Activer le voucher'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(ctx); WhatsAppHelper.openWhatsApp(); },
              icon: const Icon(Icons.chat, size: 16),
              label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryGreen, side: const BorderSide(color: AppColors.primaryGreen), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(ctx); _showPointsPaymentDialog(); },
              icon: const Icon(Icons.stars, size: 16),
              label: const Text('Points', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryAmber, side: const BorderSide(color: AppColors.primaryAmber), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () { Navigator.pop(ctx); WhatsAppHelper.openWhatsApp(); },
            child: const Text('Appeler le support', style: TextStyle(fontSize: 12)),
          ),
        ]),
      ),
    );
  }

  Widget _voucherCodeField() {
    return TextField(
      controller: _voucherController,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        hintText: 'OFF-XXXX-XXXX ou PTS-XXXX',
        prefixIcon: const Icon(Icons.vpn_key, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _activateVoucherFromDialog() async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez un code'), backgroundColor: AppColors.primaryRed));
      return;
    }
    if (code.startsWith('OFF-')) {
      final boutiqueId = _boutiqueId ?? 'B-0000-XX';
      final error = await OfflineVoucherService.validateOfflineVoucher(code, boutiqueId);
      if (error != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.primaryRed));
        return;
      }
      final plan = OfflineVoucherService.extractPlanFromCode(code);
      if (plan == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code invalide'), backgroundColor: AppColors.primaryRed));
        return;
      }
      await OfflineVoucherService.markCodeUsed(code);
      final prefs = await SharedPreferences.getInstance();
      final expiry = DateTime.now().add(const Duration(days: 30));
      await prefs.setString('subscription_plan', plan);
      await prefs.setString('subscription_expiry', expiry.toIso8601String());
      await prefs.setBool('has_subscription', true);
      if (mounted) {
        Navigator.pop(context);
        setState(() => _hasSubscription = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan $plan active !'), backgroundColor: AppColors.primaryGreen));
      }
    } else if (code.startsWith('PTS-')) {
      final amount = PointsService.extractPointsAmount(code);
      if (amount > 0) {
        await PointsService.addPoints(amount);
        await PointsService.markCodeUsed(code);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$amount points ajoutes !'), backgroundColor: AppColors.primaryGreen));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code points invalide'), backgroundColor: AppColors.primaryRed));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format de code invalide'), backgroundColor: AppColors.primaryRed));
    }
  }

  void _showPointsPaymentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Payer avec des points'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          FutureBuilder<int>(
            future: PointsService.getPointsBalance(),
            builder: (ctx, snap) {
              final balance = snap.data ?? 0;
              return Text('Solde: $balance points', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 16),
          const Text('Plans disponibles:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...PointsService.planPrices.entries.map((e) => ListTile(
            dense: true,
            title: Text(PointsService.planLabels[e.key] ?? e.key),
            trailing: Text('${e.value} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              final balance = await PointsService.getPointsBalance();
              if (balance >= e.value) {
                await PointsService.deductPoints(e.value);
                final prefs = await SharedPreferences.getInstance();
                final expiry = DateTime.now().add(const Duration(days: 30));
                await prefs.setString('subscription_plan', e.key);
                await prefs.setString('subscription_expiry', expiry.toIso8601String());
                await prefs.setBool('has_subscription', true);
                if (mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  setState(() => _hasSubscription = true);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.key} active avec ${e.value} points !'), backgroundColor: AppColors.primaryGreen));
                }
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Points insuffisants'), backgroundColor: AppColors.primaryRed));
              }
            },
          )),
        ]),
      ),
    );
  }

  void _showPinCreationDialog() {
    _tempPin = '';
    _pinStep = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline, size: 48, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text(_pinStep == 0 ? 'Creer un PIN' : 'Confirmer le PIN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_pinStep == 0 ? 'Entrez un code PIN a 4 chiffres' : 'Retapez le code PIN'),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < _tempPin.length ? AppColors.primaryPurple : AppColors.border,
              ),
            ))),
            const SizedBox(height: 20),
            _buildNumpad(ctx, setDialogState),
          ]),
        ),
      ),
    );
  }

  Widget _buildNumpad(BuildContext ctx, StateSetter setDialogState) {
    return Column(children: [
      for (var row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row.map((n) {
          if (n == '') return const SizedBox(width: 64, height: 52);
          return GestureDetector(
            onTap: () {
              setDialogState(() {
                if (n == '⌫') {
                  if (_tempPin.isNotEmpty) _tempPin = _tempPin.substring(0, _tempPin.length - 1);
                } else if (_tempPin.length < 4) {
                  _tempPin += n;
                }
                if (_tempPin.length == 4) {
                  if (_pinStep == 0) {
                    _pinStep = 1;
                    _tempPin = '';
                  } else {
                    Navigator.pop(ctx);
                  }
                }
              });
            },
            child: Container(
              width: 64, height: 52,
              decoration: BoxDecoration(color: n == '⌫' ? AppColors.primaryRed.withAlpha(25) : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(n, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: n == '⌫' ? AppColors.primaryRed : AppColors.textDark)),
            ),
          );
        }).toList()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connexion vendeur'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _BoutiqueInfoWidget(storeName: _storeName, ownerName: _ownerName, boutiqueId: _boutiqueId),
            const SizedBox(height: 24),
            if (!_hasSubscription) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primaryAmber.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryAmber.withAlpha(80))),
                child: Row(children: [
                  const Icon(Icons.warning_amber, color: AppColors.primaryAmber),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Abonnement expire', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Activez votre abonnement', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ])),
                  TextButton(onPressed: _showSubscriptionRequiredDialog, child: const Text('Activer')),
                ]),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Selectionnez votre profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildVendorGrid(),
            const SizedBox(height: 20),
            if (_selectedVendorId != null && !_showNumpad) ...[
              const Text('Entrez votre PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPinEntry(),
            ],
            if (_showNumpad) ...[
              const SizedBox(height: 16),
              const Text('Entrez votre PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 16, height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < _enteredPin.length ? AppColors.primaryPurple : AppColors.border),
              ))),
              const SizedBox(height: 16),
              _buildNumpadInline(),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _BoutiqueInfoWidget({required String storeName, required String ownerName, String? boutiqueId}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.store, color: AppColors.primaryPurple, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(ownerName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          if (boutiqueId != null) Text(boutiqueId, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'monospace')),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: const Text('Actif', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildVendorGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _vendorAvatar('PP', AppColors.primaryPurple, 0),
          const SizedBox(width: 12),
          _vendorAvatar('V1', AppColors.primaryBlue, 1),
          const SizedBox(width: 12),
          _vendorAvatar('V2', AppColors.primaryGreen, 2),
          const SizedBox(width: 12),
          _vendorAvatar('+', Colors.grey, 3),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _vendorLabel('Proprietaire'),
          _vendorLabel('Vendeur 1'),
          _vendorLabel('Vendeur 2'),
          _vendorLabel('Ajouter'),
        ]),
      ]),
    );
  }

  Widget _vendorAvatar(String text, Color color, int index) {
    final isSelected = _selectedVendorId == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _showPinCreationDialog();
          return;
        }
        setState(() {
          _selectedVendorId = index;
          _enteredPin = '';
          _showNumpad = true;
        });
      },
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Center(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color))),
      ),
    );
  }

  Widget _vendorLabel(String text) {
    return SizedBox(width: 56, child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)));
  }

  Widget _buildPinEntry() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '****',
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.lock, size: 20),
          ),
          onSubmitted: (v) => _validatePin(v),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _validatePin(_pinController.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _buildNumpadInline() {
    return Column(children: [
      for (var row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row.map((n) {
          if (n == '') return const SizedBox(width: 64, height: 52);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (n == '⌫') {
                  if (_enteredPin.isNotEmpty) _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
                } else if (_enteredPin.length < 4) {
                  _enteredPin += n;
                }
                if (_enteredPin.length == 4) {
                  _validatePin(_enteredPin);
                }
              });
            },
            child: Container(
              width: 64, height: 52,
              decoration: BoxDecoration(color: n == '⌫' ? AppColors.primaryRed.withAlpha(25) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              alignment: Alignment.center,
              child: Text(n, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: n == '⌫' ? AppColors.primaryRed : AppColors.textDark)),
            ),
          );
        }).toList()),
    ]);
  }

  Future<void> _validatePin(String pin) async {
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le PIN doit avoir 4 chiffres'), backgroundColor: AppColors.primaryRed));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('vendor_pin_$_selectedVendorId');
    if (savedPin == null) {
      await prefs.setString('vendor_pin_$_selectedVendorId', pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN cree avec succes !'), backgroundColor: AppColors.primaryGreen));
        context.go('/');
      }
    } else if (savedPin == pin) {
      await prefs.setInt('current_vendor_id', _selectedVendorId ?? 0);
      if (mounted) context.go('/');
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN incorrect'), backgroundColor: AppColors.primaryRed));
    }
    _pinController.clear();
    setState(() => _enteredPin = '');
  }
}
