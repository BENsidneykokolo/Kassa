import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/coupon.dart';
import '../../providers/providers.dart';

class AddCouponScreen extends ConsumerStatefulWidget {
  const AddCouponScreen({super.key});

  @override
  ConsumerState<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends ConsumerState<AddCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxUsesController = TextEditingController();
  String _selectedDiscountType = 'pourcentage';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  void _generateCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    final code = 'PROMO$random';
    setState(() => _codeController.text = code);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final coupon = Coupon(
        id: const Uuid().v4(),
        code: _codeController.text.toUpperCase(),
        discountType: _selectedDiscountType,
        discountValue: double.parse(_discountValueController.text),
        minPurchase: _minPurchaseController.text.isNotEmpty
            ? double.parse(_minPurchaseController.text)
            : 0,
        maxUses: _maxUsesController.text.isNotEmpty
            ? int.parse(_maxUsesController.text)
            : 0,
        usedCount: 0,
        startDate: _startDate,
        endDate: _endDate,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await ref.read(couponsProvider.notifier).addCoupon(coupon);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon cree avec succes')),
        );
        context.go('/coupons');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau coupon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Code du coupon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Code',
                                prefixIcon: Icon(Icons.confirmation_num),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un code';
                                }
                                if (value.length < 4) {
                                  return '4 caracteres minimum';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _generateCode,
                            icon: const Icon(Icons.casino),
                            tooltip: 'Generer un code',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remise',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDiscountType,
                        decoration: const InputDecoration(
                          labelText: 'Type de remise',
                          prefixIcon: Icon(Icons.discount),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pourcentage',
                            child: Text('Pourcentage (%)'),
                          ),
                          DropdownMenuItem(
                            value: 'fixe',
                            child: Text('Montant fixe (FCFA)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDiscountType = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _discountValueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _selectedDiscountType == 'pourcentage'
                              ? 'Pourcentage de remise'
                              : 'Montant de la remise (FCFA)',
                          prefixIcon: const Icon(Icons.percent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la valeur';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Veuillez entrer un montant valide';
                          }
                          if (_selectedDiscountType == 'pourcentage' &&
                              num > 100) {
                            return 'Le pourcentage ne peut pas depasser 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _minPurchaseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Achat minimum (FCFA)',
                          prefixIcon: Icon(Icons.shopping_cart),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxUsesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre max d\'utilisations',
                          prefixIcon: Icon(Icons.people),
                          hintText: '0 = illimite',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Periode de validite',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date de debut',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date de fin',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Creer le coupon'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
