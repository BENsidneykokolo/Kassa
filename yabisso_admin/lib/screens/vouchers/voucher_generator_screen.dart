import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../services/voucher_generator_service.dart';

class VoucherGeneratorScreen extends StatefulWidget {
  const VoucherGeneratorScreen({super.key});
  @override
  State<VoucherGeneratorScreen> createState() => _VoucherGeneratorScreenState();
}

class _VoucherGeneratorScreenState extends State<VoucherGeneratorScreen> {
  static const _primary = AppColors.primaryGreen;

  String _businessType = 'boutique';
  final _businessIdController = TextEditingController();
  final _prestataireIdController = TextEditingController();
  String _voucherMode = 'subscription';
  String _selectedPlan = 'BASIC';
  String _selectedDuration = '30';
  final _pointsController = TextEditingController();
  String? _generatedCode;
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _requestHistory = [];

  final _plans = {
    'DEBUTANT': 1000,
    'MICRO': 2000,
    'BASIC': 3000,
    'PREMIUM': 5000,
    'UNLIMITED': 10000,
  };

  final _quickPoints = [1000, 2000, 3000, 5000];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadRequestHistory();
  }

  @override
  void dispose() {
    _businessIdController.dispose();
    _prestataireIdController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('voucher_history') ?? [];
    setState(() {
      _history = list.map((e) {
        final parts = e.split('|||');
        return {
          'type': parts[0],
          'code': parts[1],
          'date': parts[2],
          'businessType': parts.length > 3 ? parts[3] : '',
          'plan': parts.length > 4 ? parts[4] : '',
          'points': parts.length > 5 ? parts[5] : '',
        };
      }).toList();
    });
  }

  Future<void> _loadRequestHistory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subscription_requests')
          .where('status', isIn: ['accepted', 'rejected'])
          .orderBy('processedAt', descending: true)
          .limit(20)
          .get();
      if (!mounted) return;
      setState(() {
        _requestHistory = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'type': 'REQ',
            'status': data['status'] ?? '',
            'storeName': data['storeName'] ?? '',
            'plan': data['requestedPlan'] ?? '',
            'date': data['processedAt'] ?? '',
            'notes': data['notes'] ?? '',
            'rejectionReason': data['rejectionReason'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading request history: $e');
    }
  }

  Future<void> _saveToHistory(String type, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('voucher_history') ?? [];
    final now = DateTime.now().toLocal().toString().substring(0, 16);
    final plan = _voucherMode == 'points' ? '' : _selectedPlan;
    final points = _voucherMode == 'points' ? (_pointsController.text) : '';
    list.insert(0, '$type|||$code|||$now|||$_businessType|||$plan|||$points');
    if (list.length > 50) list.removeLast();
    await prefs.setStringList('voucher_history', list);
    await _loadHistory();
  }

  void _generateVoucher() {
    String code;

    if (_voucherMode == 'online') {
      code = VoucherGeneratorService.generateOnlineVoucher();
      _saveToHistory('YAB', code);
    } else if (_voucherMode == 'proprio') {
      final businessId = _businessIdController.text.trim();
      if (businessId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer l\'ID du commerce'), backgroundColor: AppColors.primaryRed),
        );
        return;
      }
      final pointsText = _pointsController.text.trim();
      if (pointsText.isEmpty || int.tryParse(pointsText) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant de points valide'), backgroundColor: AppColors.primaryRed),
        );
        return;
      }
      final points = int.parse(pointsText);
      final hash = VoucherGeneratorService._hashId(businessId);
      final hexPoints = points.toRadixString(16).toUpperCase().padLeft(4, '0');
      final check = VoucherGeneratorService._randomChars(2);
      code = 'PTS-PRO-$hash-$hexPoints-$check';
      _saveToHistory('PTS-PRO', code);
    } else if (_voucherMode == 'subscription') {
      final businessId = _businessIdController.text.trim();
      if (businessId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer l\'ID du commerce'), backgroundColor: AppColors.primaryRed),
        );
        return;
      }
      final hash = VoucherGeneratorService._hashId(businessId);
      final random = VoucherGeneratorService._randomChars(4);
      code = 'OFF-PRO-$hash-$random';
      _saveToHistory('OFF-PRO', code);
    } else {
      final businessId = _businessIdController.text.trim();
      if (businessId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer l\'ID du commerce'), backgroundColor: AppColors.primaryRed),
        );
        return;
      }
      final pointsText = _pointsController.text.trim();
      if (pointsText.isEmpty || int.tryParse(pointsText) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant de points valide'), backgroundColor: AppColors.primaryRed),
        );
        return;
      }
      final points = int.parse(pointsText);
      code = VoucherGeneratorService.generatePointsVoucher(_businessType, businessId, points);
      _saveToHistory('PTS', code);
    }

    setState(() => _generatedCode = code);
    HapticFeedback.mediumImpact();
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copié: $code'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getBusinessIcon() {
    switch (_businessType) {
      case 'restaurant':
        return 'R';
      case 'hotel':
        return 'H';
      default:
        return 'B';
    }
  }

  Color _getBusinessColor() {
    switch (_businessType) {
      case 'restaurant':
        return AppColors.primaryRed;
      case 'hotel':
        return AppColors.primaryBlue;
      default:
        return _primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessColor = _getBusinessColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Générateur de vouchers'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildBusinessTypeSelector(),
            const SizedBox(height: 20),
            _buildBusinessIdInput(),
            const SizedBox(height: 16),
            _buildPrestataireIdInput(),
            const SizedBox(height: 20),
            _buildVoucherModeToggle(),
            const SizedBox(height: 16),
            if (_voucherMode == 'online') ...[
              _buildPlanSelector(),
              const SizedBox(height: 16),
              _buildDurationSelector(),
            ] else if (_voucherMode == 'subscription') ...[
              _buildPlanSelector(),
            ] else if (_voucherMode == 'proprio') ...[
              _buildPointsInput(),
            ] else if (_voucherMode == 'requests') ...[
              _buildSubscriptionRequests(),
            ] else ...[
              _buildPointsInput(),
            ],
            const SizedBox(height: 16),
            if (_voucherMode != 'requests') ...[
              _buildGenerateButton(businessColor),
              const SizedBox(height: 16),
              if (_generatedCode != null) _buildGeneratedCode(businessColor),
            ],
            const SizedBox(height: 24),
            _buildHistory(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00694C), const Color(0xFF1D9E75)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.vpn_key, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('GÉNÉRATEUR DE VOUCHERS', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Codes abonnements & points', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Générez des codes pour boutiques, restaurants et hôtels', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type de commerce', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTypeChip('Boutique', 'boutique', Icons.store, _primary),
            const SizedBox(width: 8),
            _buildTypeChip('Restaurant', 'restaurant', Icons.restaurant, AppColors.primaryRed),
            const SizedBox(width: 8),
            _buildTypeChip('Hôtel', 'hotel', Icons.hotel, AppColors.primaryBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon, Color color) {
    final isActive = _businessType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _businessType = value;
          _generatedCode = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : AppColors.border, width: isActive ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? color : Colors.grey, size: 22),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey[600],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessIdInput() {
    String hint;
    String helper;
    switch (_businessType) {
      case 'restaurant':
        hint = 'R-1234-MK';
        helper = 'Format: R-{4 chiffres}-{initiales}';
        break;
      case 'hotel':
        hint = 'H-5678-AB';
        helper = 'Format: H-{4 chiffres}-{initiales}';
        break;
      default:
        hint = 'B-4567-JP';
        helper = 'Format: B-{4 chiffres}-{initiales}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_voucherMode == 'online' ? 'ID Boutique (optionnel)' : 'ID du commerce', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _businessIdController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: hint,
            helperText: _voucherMode == 'online' ? 'Pas obligatoire pour les vouchers en ligne' : helper,
            helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getBusinessColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_getBusinessIcon(), style: TextStyle(
                color: _getBusinessColor(), fontWeight: FontWeight.bold, fontSize: 14,
              )),
            ),
          ),
          onChanged: (_) => setState(() => _generatedCode = null),
        ),
      ],
    );
  }

  Widget _buildPrestataireIdInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ID Prestataire (optionnel)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _prestataireIdController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'EMP-1234-JD',
            helperText: 'ID du vendeur/commercial',
            helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('E', style: TextStyle(
                color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14,
              )),
            ),
          ),
          onChanged: (_) => setState(() => _generatedCode = null),
        ),
      ],
    );
  }

  Widget _buildVoucherModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          _buildModeButton('En ligne', 'online'),
          _buildModeButton('Hors ligne', 'subscription'),
          _buildModeButton('Points', 'points'),
          _buildModeButton('Proprio', 'proprio'),
          _buildModeButton('Demandes', 'requests'),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String value) {
    final isActive = _voucherMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _voucherMode = value;
          _generatedCode = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14,
              color: isActive ? Colors.white : Colors.grey[600],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Forfait', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._plans.entries.map((e) => _buildPlanOption(e.key, e.value)),
      ],
    );
  }

  Widget _buildPlanOption(String plan, int price) {
    final isActive = _selectedPlan == plan;
    final color = _getPlanColor(plan);
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPlan = plan;
        _generatedCode = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? color : AppColors.border, width: isActive ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Text(plan[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(plan, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Text(
              '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Durée', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildDurationOption('30', '30 jours'),
            const SizedBox(width: 8),
            _buildDurationOption('60', '60 jours'),
            const SizedBox(width: 8),
            _buildDurationOption('90', '90 jours'),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(String value, String label) {
    final isActive = _selectedDuration == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedDuration = value;
          _generatedCode = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? _primary : AppColors.border, width: isActive ? 2 : 1),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13,
              color: isActive ? _primary : Colors.grey[600],
            )),
          ),
        ),
      ),
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan) {
      case 'MICRO':
        return Colors.grey;
      case 'BASIC':
        return _primary;
      case 'PREMIUM':
        return AppColors.primaryAmber;
      case 'UNLIMITED':
        return AppColors.primaryBlue;
      default:
        return _primary;
    }
  }

  Widget _buildPointsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Montant de points', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPoints.map((p) => _buildQuickPointsButton(p)).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pointsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Montant personnalisé',
            filled: true,
            fillColor: Colors.white,
            suffixText: 'points',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 2),
            ),
          ),
          onChanged: (_) => setState(() => _generatedCode = null),
        ),
      ],
    );
  }

  Widget _buildQuickPointsButton(int points) {
    final isActive = _pointsController.text == points.toString();
    return GestureDetector(
      onTap: () {
        setState(() {
          _pointsController.text = points.toString();
          _generatedCode = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryAmber.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? AppColors.primaryAmber : AppColors.border),
        ),
        child: Text(
          '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} pts',
          style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: isActive ? AppColors.primaryAmber : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(Color businessColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _generateVoucher,
        icon: const Icon(Icons.vpn_key, size: 20),
        label: const Text('Générer le code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: businessColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 3,
          shadowColor: businessColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildGeneratedCode(Color businessColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: businessColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: businessColor.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: businessColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _voucherMode == 'online' ? 'VOUCHER EN LIGNE' : (_voucherMode == 'subscription' ? 'VOUCHER HORS LIGNE' : 'VOUCHER POINTS'),
              style: TextStyle(color: businessColor, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _generatedCode!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2,
                color: businessColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyCode(_generatedCode!),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copier le code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: businessColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.card_membership, size: 20, color: _primary),
            const SizedBox(width: 8),
            const Text('Demandes d\'abonnement', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Validez ou refusez les demandes des commerces', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('subscription_requests')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: AppColors.primaryRed),
                    const SizedBox(height: 8),
                    Text('Erreur: ${snapshot.error}', style: const TextStyle(color: AppColors.primaryRed, fontSize: 13)),
                  ],
                ),
              );
            }
            final docs = snapshot.data?.docs ?? [];
            final pending = docs.where((d) => (d.data() as Map)['status'] == 'pending').toList();
            if (pending.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Aucune demande en attente', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pending.length} demande${pending.length > 1 ? 's' : ''} en attente',
                    style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                ...pending.map((doc) => _buildRequestCard(doc)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final storeName = data['storeName'] ?? 'N/A';
    final ownerName = data['ownerName'] ?? 'N/A';
    final phone = data['phone'] ?? '';
    final plan = data['requestedPlan'] ?? '';
    final createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now();

    final planColor = _getPlanColor(plan.toUpperCase());
    final planPrice = _getPlanPrice(plan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryAmber.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top, color: AppColors.primaryAmber, size: 16),
                const SizedBox(width: 6),
                const Text('En attente', style: TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.w700, fontSize: 12)),
                const Spacer(),
                Text(_formatDate(createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.store, color: _primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Propriétaire: $ownerName', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: planColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: planColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: planColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(plan.isNotEmpty ? plan[0].toUpperCase() : '?', style: TextStyle(color: planColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Forfait $plan', style: TextStyle(color: planColor, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(planPrice, style: TextStyle(color: planColor.withValues(alpha: 0.7), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: phone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Téléphone copié: $phone'), backgroundColor: AppColors.successGreen, duration: const Duration(seconds: 2)),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(phone, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                        const SizedBox(width: 4),
                        Icon(Icons.copy, size: 12, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptRequest(doc),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectRequest(doc),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Refuser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanPrice(String plan) {
    switch (plan.toLowerCase()) {
      case 'débutant': case 'debutant': return '1 000 FCFA/mois';
      case 'micro': return '2 000 FCFA/mois';
      case 'basic': case 'basique': return '3 000 FCFA/mois';
      case 'premium': return '5 000 FCFA/mois';
      case 'illimité': case 'unlimited': return '10 000 FCFA/mois';
      default: return '';
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/$y à $h:$min';
  }

  Future<void> _acceptRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accepter la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutique: ${data['storeName'] ?? ''}'),
            Text('Forfait: ${data['requestedPlan'] ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Notes (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('subscription_requests').doc(doc.id).update({
        'status': 'accepted',
        'processedAt': DateTime.now().toIso8601String(),
        'notes': notesController.text.trim(),
      });
      _loadRequestHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande acceptée — l\'abonnement est maintenant actif'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    }
  }

  Future<void> _rejectRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutique: ${data['storeName'] ?? ''}'),
            Text('Forfait: ${data['requestedPlan'] ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Raison du refus (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('subscription_requests').doc(doc.id).update({
        'status': 'rejected',
        'processedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reasonController.text.trim(),
      });
      _loadRequestHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande refusée'), backgroundColor: AppColors.primaryRed),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    }
  }

  Widget _buildHistory() {
    final allItems = [..._requestHistory, ..._history];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 20, color: _primary),
            const SizedBox(width: 8),
            const Text('Historique', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (allItems.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('voucher_history');
                  setState(() {
                    _history = [];
                    _requestHistory = [];
                  });
                },
                child: const Text('Effacer', style: TextStyle(color: AppColors.primaryRed, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (allItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Aucun élément dans l\'historique', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          )
        else
          ...allItems.take(15).map((item) => item['type'] == 'REQ'
              ? _buildRequestHistoryItem(item)
              : _buildHistoryItem(item)),
      ],
    );
  }

  Widget _buildRequestHistoryItem(Map<String, dynamic> item) {
    final isAccepted = item['status'] == 'accepted';
    final color = isAccepted ? AppColors.successGreen : AppColors.primaryRed;
    final label = isAccepted ? 'Acceptée' : 'Refusée';
    final dateStr = item['date'] ?? '';
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) formattedDate = _formatDate(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isAccepted ? Icons.check_circle : Icons.cancel, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['storeName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Forfait ${item['plan'] ?? ''} • $label', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(formattedDate, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final type = item['type'] ?? 'OFF';
    final isYab = type == 'YAB';
    final isPts = type == 'PTS';
    final isPro = type.startsWith('PTS-PRO') || type == 'OFF-PRO';
    final color = isYab ? AppColors.primaryBlue : (isPts ? AppColors.primaryAmber : (isPro ? AppColors.primaryRed : _primary));
    final label = isYab ? 'En ligne' : (isPts ? 'Points' : (isPro ? 'Proprio' : 'Hors ligne'));
    final detail = isYab ? '${item['plan'] ?? ''} • $_selectedDuration j' : (isPts || isPro ? '${item['points'] ?? ''} pts' : (item['plan'] ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isYab ? Icons.language : (isPts ? Icons.stars : (isPro ? Icons.business : Icons.card_membership)), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('$label • ${item['date'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(detail, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => _copyCode(item['code'] ?? ''),
                child: const Icon(Icons.copy, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
