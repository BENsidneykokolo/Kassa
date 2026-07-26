import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/offline_voucher_service.dart';

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
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildWelcomeSection(),
              const SizedBox(height: 28),
              _buildFormCard(),
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
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: const Icon(Icons.analytics_outlined, size: 40, color: AppColors.primary),
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      children: [
        Text(
          'Bienvenue sur Yabisso Analytics',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        SizedBox(height: 8),
        Text(
          'Analysez vos ventes, suivez vos KPIs et maximisez vos benefices.',
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
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13)),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isLogin ? 'Se connecter' : "S'inscrire",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              onTap: () => setState(() { _isLogin = true; _error = null; }),
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
              onTap: () => setState(() { _isLogin = false; _error = null; }),
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
        label: 'Numero de telephone',
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
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey),
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
        label: 'Nom du proprietaire',
        hint: 'Ex: Jean-Pierre Mbala',
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _phoneController,
        label: 'Numero de telephone',
        hint: '+242 06 XXX XXXX',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _passwordController,
        label: 'Creer un mot de passe',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey),
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
          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey),
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        setState(() { _error = 'Aucun compte trouve. Inscrivez-vous d\'abord.'; _loading = false; });
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
        setState(() { _error = 'Numero ou mot de passe incorrect'; _loading = false; });
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
        setState(() => _error = 'Le mot de passe doit contenir au moins 4 caracteres');
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
              style: TextStyle(color: Colors.grey[700], decoration: TextDecoration.underline, fontWeight: FontWeight.w500),
            ),
            const TextSpan(text: ' et notre '),
            TextSpan(
              text: 'Politique de Confidentialite',
              style: TextStyle(color: Colors.grey[700], decoration: TextDecoration.underline, fontWeight: FontWeight.w500),
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
