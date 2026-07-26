import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../services/offline_voucher_service.dart';
import '../../helpers/whatsapp_helper.dart';
import '../../services/points_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Login controllers
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _regStoreNameController = TextEditingController();
  final _regOwnerNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  // Voucher
  final _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regStoreNameController.dispose();
    _regOwnerNameController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginPhoneController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final savedPhone = await secureStorage.read(key: 'user_phone');
    final savedPassword = await secureStorage.read(key: 'user_password');
    if (savedPhone == null || savedPassword == null) {
      setState(() => _isLoading = false);
      _showError('Aucun compte trouve. Inscrivez-vous d\'abord.');
      return;
    }
    if (_loginPhoneController.text == savedPhone && _loginPasswordController.text == savedPassword) {
      await prefs.setBool('is_logged_in', true);
      setState(() => _isLoading = false);
      context.go('/vendor-auth');
    } else {
      setState(() => _isLoading = false);
      _showError('Numero ou mot de passe incorrect');
    }
  }

  Future<void> _register() async {
    if (_regStoreNameController.text.isEmpty || _regOwnerNameController.text.isEmpty ||
        _regPhoneController.text.isEmpty || _regPasswordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }
    if (_regPasswordController.text != _regConfirmPasswordController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }
    if (_regPasswordController.text.length < 4) {
      _showError('Le mot de passe doit avoir au moins 4 caracteres');
      return;
    }
    setState(() => _isLoading = true);
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: 'user_phone', value: _regPhoneController.text);
    await secureStorage.write(key: 'user_password', value: _regPasswordController.text);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _regOwnerNameController.text);
    await prefs.setString('store_name', _regStoreNameController.text);
    await prefs.setBool('is_logged_in', true);
    final boutiqueId = OfflineVoucherService.generateBoutiqueId(_regPhoneController.text, _regStoreNameController.text);
    await OfflineVoucherService.saveBoutiqueId(boutiqueId);
    setState(() => _isLoading = false);
    context.go('/vendor-auth');
  }

  Future<void> _activateVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      _showError('Entrez le code voucher');
      return;
    }
    setState(() => _isLoading = true);
    final boutiqueId = await OfflineVoucherService.getOrCreateBoutiqueId();
    if (boutiqueId == null) {
      setState(() => _isLoading = false);
      _showError('Connectez-vous d\'abord pour activer un voucher');
      return;
    }
    final error = await OfflineVoucherService.validateOfflineVoucher(code, boutiqueId);
    if (error != null) {
      setState(() => _isLoading = false);
      _showError(error);
      return;
    }
    final plan = OfflineVoucherService.extractPlanFromCode(code);
    if (plan == null) {
      setState(() => _isLoading = false);
      _showError('Code invalide');
      return;
    }
    await OfflineVoucherService.markCodeUsed(code);
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 30));
    await prefs.setString('subscription_plan', plan);
    await prefs.setString('subscription_expiry', expiry.toIso8601String());
    await prefs.setBool('has_subscription', true);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan $plan active avec succes !'), backgroundColor: AppColors.primaryGreen));
      context.go('/vendor-auth');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.primaryRed));
  }

  void _showPlanSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.5,
        expand: false,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Choisir un abonnement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Selectionnez votre plan', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  _planTile('MICRO', 1000, '30 jours', 'Fonctionnalites de base', AppColors.primaryGreen),
                  _planTile('BASIC', 1500, '30 jours', 'Insights + Historique', AppColors.primaryBlue),
                  _planTile('PREMIUM', 3000, '30 jours', 'Toutes fonctionnalites', AppColors.primaryPurple),
                  _planTile('UNLIMITED', 5000, 'Illimite', 'Acces complet sans limite', AppColors.primaryAmber),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _planTile(String plan, int price, String duration, String features, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        tileColor: color.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withAlpha(80))),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.star, color: Colors.white)),
        title: Text('$plan - $price FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text('$duration\n$features', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(ctx);
          WhatsAppHelper.openWhatsApp();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 12),
            const Text('Yabisso IA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Assistant IA pour commercants', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(10)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                tabs: const [Tab(text: 'Connexion'), Tab(text: "S'inscrire")],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(),
                  _buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 16),
        TextField(
          controller: _loginPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numero de telephone',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _showPlanSelection,
          child: const Text('Activer avec un voucher', style: TextStyle(color: AppColors.primaryPurple)),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: WhatsAppHelper.openWhatsApp,
          icon: const Icon(Icons.chat, color: AppColors.primaryGreen),
          label: const Text('Payer via WhatsApp', style: TextStyle(color: AppColors.primaryGreen)),
        ),
      ]),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 16),
        TextField(
          controller: _regStoreNameController,
          decoration: InputDecoration(
            labelText: 'Nom du magasin',
            prefixIcon: const Icon(Icons.store),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regOwnerNameController,
          decoration: InputDecoration(
            labelText: 'Nom du proprietaire',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numero de telephone',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regConfirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Creer mon compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _showPlanSelection,
          child: const Text('Activer avec un voucher', style: TextStyle(color: AppColors.primaryPurple)),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: WhatsAppHelper.openWhatsApp,
          icon: const Icon(Icons.chat, color: AppColors.primaryGreen),
          label: const Text('Payer via WhatsApp', style: TextStyle(color: AppColors.primaryGreen)),
        ),
      ]),
    );
  }
}
