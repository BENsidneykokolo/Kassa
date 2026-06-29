import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _voucherMode = 'subscription';
  String _selectedPlan = 'BASIC';
  final _pointsController = TextEditingController();
  String? _generatedCode;
  List<Map<String, dynamic>> _history = [];

  final _plans = {
    'MICRO': 5000,
    'BASIC': 10000,
    'PREMIUM': 25000,
    'UNLIMITED': 50000,
  };

  final _quickPoints = [1000, 2000, 3000, 5000];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _businessIdController.dispose();
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

  Future<void> _saveToHistory(String type, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('voucher_history') ?? [];
    final now = DateTime.now().toLocal().toString().substring(0, 16);
    final plan = _voucherMode == 'subscription' ? _selectedPlan : '';
    final points = _voucherMode == 'points' ? (_pointsController.text) : '';
    list.insert(0, '$type|||$code|||$now|||$_businessType|||$plan|||$points');
    if (list.length > 50) list.removeLast();
    await prefs.setStringList('voucher_history', list);
    await _loadHistory();
  }

  void _generateVoucher() {
    final businessId = _businessIdController.text.trim();
    if (businessId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer l\'ID du commerce'), backgroundColor: AppColors.primaryRed),
      );
      return;
    }

    String code;
    if (_voucherMode == 'subscription') {
      code = VoucherGeneratorService.generateOfflineVoucher(_businessType, businessId, _selectedPlan);
      _saveToHistory('OFF', code);
    } else {
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
            const SizedBox(height: 20),
            _buildVoucherModeToggle(),
            const SizedBox(height: 16),
            if (_voucherMode == 'subscription') _buildPlanSelector() else _buildPointsInput(),
            const SizedBox(height: 16),
            _buildGenerateButton(businessColor),
            const SizedBox(height: 16),
            if (_generatedCode != null) _buildGeneratedCode(businessColor),
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
        const Text('ID du commerce', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _businessIdController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
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

  Widget _buildVoucherModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildModeButton('Abonnement', 'subscription'),
          _buildModeButton('Points', 'points'),
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
              _voucherMode == 'subscription' ? 'VOUCHER ABONNEMENT' : 'VOUCHER POINTS',
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

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 20, color: _primary),
            const SizedBox(width: 8),
            const Text('Historique', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('voucher_history');
                  setState(() => _history = []);
                },
                child: const Text('Effacer', style: TextStyle(color: AppColors.primaryRed, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Aucun voucher généré', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          )
        else
          ..._history.take(10).map((item) => _buildHistoryItem(item)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isOff = item['type'] == 'OFF';
    final color = isOff ? _primary : AppColors.primaryAmber;
    final label = isOff ? 'Abonnement' : 'Points';
    final detail = isOff ? (item['plan'] ?? '') : '${item['points'] ?? ''} pts';

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
            child: Icon(isOff ? Icons.card_membership : Icons.stars, color: color, size: 18),
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
