import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../models/admin.dart';
import '../../providers/providers.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _pin = '';
  bool _showPinEntry = false;
  Admin? _selectedAdmin;
  bool _pinError = false;
  bool _isFirstTime = false;
  String _confirmPin = '';
  String _selectedRole = 'admin';
  late AnimationController _shakeController;

  static const _primary = AppColors.primaryGreen;
  static const _bg = AppColors.background;
  static const _coral = AppColors.primaryRed;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _checkExistingAdmins();
  }

  Future<void> _checkExistingAdmins() async {
    final admins = await AuthService.instance.getAllAdmins();
    if (admins.isEmpty && mounted) {
      setState(() => _isLogin = false);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      _pinError = false;
      if (key == 'back') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (key == 'cancel') {
        _pin = '';
        _showPinEntry = false;
        _selectedAdmin = null;
      } else {
        if (_pin.length < 6) _pin += key;
      }
    });
    if (_pin.length >= 4) _validatePin();
  }

  Future<void> _validatePin() async {
    if (_isFirstTime) {
      if (_confirmPin.isEmpty) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
        });
        return;
      }
      if (_pin != _confirmPin) {
        setState(() { _pinError = true; _pin = ''; _confirmPin = ''; });
        _shakeController.forward(from: 0);
        return;
      }
      await AuthService.instance.setPin(_selectedAdmin!, _pin);
      _login();
    } else {
      if (await AuthService.instance.verifyPin(_selectedAdmin!, _pin)) {
        _login();
      } else {
        setState(() { _pinError = true; _pin = ''; });
        _shakeController.forward(from: 0);
      }
    }
  }

  void _login() {
    ref.read(currentAdminProvider.notifier).state = _selectedAdmin;
    AuthService.instance.logAction(_selectedAdmin!.id, 'connexion', 'Connexion réussie');
    context.go('/');
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: AppColors.primaryRed),
      );
      return;
    }
    final admin = await AuthService.instance.register(
      _nameController.text, _phoneController.text, _selectedRole,
    );
    setState(() {
      _selectedAdmin = admin;
      _showPinEntry = true;
      _isFirstTime = true;
      _isLogin = true;
    });
  }

  Future<void> _handleLogin() async {
    final admin = await AuthService.instance.loginByPhone(_phoneController.text);
    if (admin == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun compte trouvé'), backgroundColor: AppColors.primaryRed),
        );
      }
      return;
    }
    setState(() {
      _selectedAdmin = admin;
      _showPinEntry = true;
      _isFirstTime = admin.pinHash == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 24),
              _buildWelcomeSection(),
              const SizedBox(height: 32),
              if (_showPinEntry) _buildPinEntryView() else _buildMainView(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary, width: 3),
      ),
      child: const Icon(Icons.admin_panel_settings, size: 40, color: _primary),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          _showPinEntry ? 'Bienvenue ${_selectedAdmin?.name ?? ""}' : 'Yabisso Admin',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primary),
        ),
        const SizedBox(height: 8),
        Text(
          _showPinEntry
            ? (_isFirstTime ? 'Configurez votre code PIN' : 'Entrez votre code PIN')
            : 'Tableau de bord interne & IA',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        _buildTabSelector(),
        const SizedBox(height: 24),
        _buildFormCard(
          child: _isLogin ? _buildLoginView() : _buildRegisterView(),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTab('Connexion', _isLogin, () => setState(() => _isLogin = true)),
          _buildTab('S\'inscrire', !_isLogin, () => setState(() => _isLogin = false)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? _primary : Colors.grey)),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }

  Widget _buildLoginView() {
    return Column(
      children: [
        _buildTextField('Numéro de téléphone', Icons.phone, _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _handleLogin,
            child: const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterView() {
    return Column(
      children: [
        _buildTextField('Nom complet', Icons.person, _nameController),
        const SizedBox(height: 16),
        _buildTextField('Numéro de téléphone', Icons.phone, _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildRoleDropdown(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _register,
            child: const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rôle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              items: Admin.roles.map((r) => DropdownMenuItem(
                value: r,
                child: Text(Admin.roleLabels[r] ?? r),
              )).toList(),
              onChanged: (v) => setState(() => _selectedRole = v ?? 'admin'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool obscure = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.grey),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPinEntryView() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = _pinError ? (1 - _shakeController.value) * 8 * ((_shakeController.value * 5).toInt().isEven ? 1 : -1) : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                if (_isFirstTime && _confirmPin.isEmpty)
                  const Text('Confirmez votre PIN', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildPinDots(),
                if (_pinError) ...[
                  const SizedBox(height: 12),
                  const Text('Code incorrect', style: TextStyle(color: _coral, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                _buildNumpad(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pin.length;
        return Container(
          width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pinError ? _coral : (filled ? _primary : Colors.grey[300]),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
      ['cancel','0','back'],
    ];
    return Column(
      children: keys.map((row) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((key) {
          final isSpecial = key == 'cancel' || key == 'back';
          return Padding(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () => _onKeyPress(key),
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSpecial ? const Color(0xFFFCF0F0) : const Color(0xFFF0EDEC),
                ),
                child: Center(
                  child: key == 'back'
                    ? const Icon(Icons.backspace_outlined, color: _coral)
                    : key == 'cancel'
                      ? const Text('X', style: TextStyle(color: _coral, fontWeight: FontWeight.bold, fontSize: 18))
                      : Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          );
        }).toList(),
      )).toList(),
    );
  }
}
