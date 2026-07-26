import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/offline_voucher_service.dart';
import '../../helpers/whatsapp_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn && mounted) {
      context.go('/vendor-auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildWelcomeSection(),
              const SizedBox(height: 28),
              _buildFormCard(),
              const SizedBox(height: 20),
              _buildSubscriptionCard(),
              const SizedBox(height: 20),
              _buildLegalText(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange, width: 3),
      ),
      child: const Icon(Icons.dynamic_form, size: 40, color: AppColors.primaryOrange),
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      children: [
        Text(
          'Bienvenue sur Yabisso Forms',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        SizedBox(height: 8),
        Text(
          'Créez des formulaires dynamiques pour votre business.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTabSelector(),
            const SizedBox(height: 28),
            if (_isLogin) ..._buildLoginFields() else ..._buildRegisterFields(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.primaryRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.primaryRed, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isLogin ? 'Se connecter' : "S'inscrire",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showVoucherDialog,
                icon: const Icon(Icons.vpn_key, size: 20),
                label: const Text('Activer avec un voucher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isLogin = true;
                _error = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isLogin
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]
                      : null,
                ),
                child: Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isLogin ? AppColors.textDark : AppColors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isLogin = false;
                _error = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isLogin
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]
                      : null,
                ),
                child: Text(
                  "S'inscrire",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_isLogin ? AppColors.textDark : AppColors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoginFields() {
    return [
      _buildTextField(
        controller: _phoneController,
        label: 'Numéro de téléphone',
        hint: '+242 06 XXX XXXX',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _passwordController,
        label: 'Mot de passe',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ];
  }

  List<Widget> _buildRegisterFields() {
    return [
      _buildTextField(
        controller: _storeNameController,
        label: 'Nom du magasin / boutique',
        hint: 'Ex: Boutique Mama Jeanne',
        icon: Icons.store_outlined,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _ownerNameController,
        label: 'Nom du propriétaire',
        hint: 'Ex: Jean-Pierre Mbala',
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _phoneController,
        label: 'Numéro de téléphone',
        hint: '+242 06 XXX XXXX',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _passwordController,
        label: 'Créer un mot de passe',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _confirmPasswordController,
        label: 'Confirmer le mot de passe',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscure: _obscureConfirm,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.grey,
          ),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.grey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _error = null);

    if (_isLogin) {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      if (phone.isEmpty || password.isEmpty) {
        setState(() => _error = 'Veuillez remplir tous les champs');
        return;
      }

      setState(() => _loading = true);

      const secureStorage = FlutterSecureStorage();
      final savedPhone = await secureStorage.read(key: 'user_phone');
      final savedPass = await secureStorage.read(key: 'user_password');

      if (savedPhone == null) {
        setState(() {
          _error = 'Aucun compte trouvé. Inscrivez-vous d\'abord.';
          _loading = false;
        });
        return;
      }

      if (savedPass != null && phone == savedPhone && password == savedPass) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        final name = prefs.getString('user_name') ?? 'Boutique';
        final boutiqueId = OfflineVoucherService.generateBoutiqueId(phone, name);
        await OfflineVoucherService.saveBoutiqueId(boutiqueId);
        if (mounted) context.go('/vendor-auth');
      } else {
        setState(() {
          _error = 'Numéro ou mot de passe incorrect';
          _loading = false;
        });
      }
    } else {
      final storeName = _storeNameController.text.trim();
      final ownerName = _ownerNameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (storeName.isEmpty || ownerName.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        setState(() => _error = 'Veuillez remplir tous les champs');
        return;
      }

      if (password.length < 4) {
        setState(() => _error = 'Le mot de passe doit contenir au moins 4 caractères');
        return;
      }

      if (password != confirmPassword) {
        setState(() => _error = 'Les mots de passe ne correspondent pas');
        return;
      }

      setState(() => _loading = true);

      final prefs = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'user_phone', value: phone);
      await secureStorage.write(key: 'user_password', value: password);
      await prefs.setString('user_name', ownerName);
      await prefs.setString('store_name', storeName);
      await prefs.setBool('is_logged_in', true);

      try {
        final db = DatabaseHelper.instance;
        await db.setSetting('store_name', storeName);
        await db.setSetting('owner_name', ownerName);
        await db.setSetting('store_phone', phone);
      } catch (_) {}

      final boutiqueId = OfflineVoucherService.generateBoutiqueId(phone, ownerName);
      await OfflineVoucherService.saveBoutiqueId(boutiqueId);

      if (mounted) context.go('/vendor-auth');
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _buildSubscriptionCard() {
    return GestureDetector(
      onTap: _showPlanSelectionDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCEBEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abonnement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryRed),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Renouvellez pour continuer.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Payer →',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
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
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, size: 32, color: AppColors.primaryOrange),
            ),
            const SizedBox(height: 16),
            const Text('Choisissez votre abonnement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Sélectionnez le plan qui vous convient',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            _buildPlanTile(ctx, 'Micro', '5 formulaires max', Icons.store_mall_directory_outlined, const Color(0xFFF5A623)),
            _buildPlanTile(ctx, 'Basic', '15 formulaires max', Icons.storefront, AppColors.primaryBlue),
            _buildPlanTile(ctx, 'Premium', '50 formulaires max', Icons.diamond_outlined, AppColors.primaryGreen),
            _buildPlanTile(ctx, 'Illimité', 'Formulaires illimités', Icons.all_inclusive, const Color(0xFF7C3AED)),
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

  Widget _buildPlanTile(BuildContext ctx, String plan, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            _sendWhatsAppWithPlan(plan);
          },
          icon: Icon(icon, color: color, size: 22),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 16)),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppWithPlan(String plan) async {
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    final idText = boutiqueId != null ? ' Mon ID boutique: $boutiqueId' : '';
    final prefs = await SharedPreferences.getInstance();
    final hasSub = prefs.getBool('has_subscription') ?? false;
    final action = hasSub ? 'renouveler mon abonnement' : 'prendre un abonnement';
    final message = Uri.encodeComponent(
        'Bonjour, je souhaite $action Yabisso Forms $plan.$idText');
    if (mounted) {
      await WhatsAppHelper.showChoice(
        context: context,
        message: message,
        groupType: 'subscription',
      );
    }
  }

  Future<void> _showVoucherDialog() async {
    final controller = TextEditingController();
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activer un abonnement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez le code voucher reçu:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'YAB-XXXX-XXXX ou OFF-XXXX-XXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
            ),
            const SizedBox(height: 8),
            Text('Les codes OFF-XXXX-XXXX ne nécessitent pas Internet',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim().toUpperCase();
              if (code.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Entrez un code'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx, true);
              if (code.startsWith('OFF-')) {
                await _validateOfflineVoucher(code);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _validateOfflineVoucher(String code) async {
    setState(() => _loading = true);
    try {
      final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
      if (boutiqueId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune boutique enregistrée. Inscrivez-vous d\'abord.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final error = await OfflineVoucherService.validateOfflineVoucher(code, boutiqueId);
      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
          );
        }
        return;
      }

      final plan = OfflineVoucherService.extractPlanFromCode(code) ?? 'BASIC';
      final limit = OfflineVoucherService.getMaxFormsForPlan(plan);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_subscription', true);
      final now = DateTime.now();
      final expires = now.add(const Duration(days: 30));
      await prefs.setString('subscription_expires', expires.toIso8601String());
      await prefs.setString('subscription_start', now.toIso8601String());
      await prefs.setString('subscription_plan', plan);
      if (limit != null) {
        await prefs.setInt('max_forms', limit);
      } else {
        await prefs.remove('max_forms');
      }
      await prefs.setString('voucher_code', code);
      await prefs.setBool('is_logged_in', true);

      await OfflineVoucherService.markCodeUsed(code);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abonnement activé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/vendor-auth');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildLegalText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5),
          children: [
            const TextSpan(text: 'En continuant, vous acceptez nos '),
            TextSpan(
              text: 'Conditions',
              style: TextStyle(
                color: Colors.grey[700],
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: ' et notre '),
            TextSpan(
              text: 'Politique de Confidentialité',
              style: TextStyle(
                color: Colors.grey[700],
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
