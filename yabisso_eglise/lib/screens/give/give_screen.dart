import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../providers/providers.dart';

class GiveScreen extends ConsumerStatefulWidget {
  const GiveScreen({super.key});

  @override
  ConsumerState<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends ConsumerState<GiveScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  double _selectedAmount = 0;
  String _purpose = 'tithe';
  String _paymentMethod = 'mobile_money';
  bool _isAnonymous = false;

  static const _quickAmounts = [1000.0, 2000.0, 5000.0, 10000.0, 25000.0, 50000.0];

  static const _purposes = {
    'tithe': 'Dîme',
    'offering': 'Offrande',
    'building': 'Fonds de construction',
    'missions': 'Missions',
    'charity': 'Charité',
    'other': 'Autre',
  };

  static const _paymentMethods = {
    'mobile_money': 'Mobile Money',
    'cash': 'Espèces',
    'bank': 'Virement bancaire',
  };

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  Future<void> _processDonation() async {
    final amount = double.tryParse(_amountController.text) ?? _selectedAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    final db = DatabaseHelper.instance;
    final donation = {
      'id': const Uuid().v4(),
      'donor_name': _isAnonymous ? null : _nameController.text,
      'donor_phone': _isAnonymous ? null : _phoneController.text,
      'amount': amount,
      'purpose': _purpose,
      'payment_method': _paymentMethod,
      'is_anonymous': _isAnonymous ? 1 : 0,
      'date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insertDonation(donation);

    if (mounted) {
      ref.invalidate(donationsProvider);
      _showReceipt(amount);
    }
  }

  void _showReceipt(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Reçu de donation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            _receiptRow('Montant', '${amount.toInt()} FC'),
            _receiptRow('Objet', _purposes[_purpose] ?? _purpose),
            _receiptRow('Méthode', _paymentMethods[_paymentMethod] ?? _paymentMethod),
            _receiptRow('Donateur', _isAnonymous ? 'Anonyme' : _nameController.text),
            _receiptRow('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            _receiptRow('Réf', 'DON-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
            const Divider(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _amountController.clear();
                _selectedAmount = 0;
                _nameController.clear();
                _phoneController.clear();
                _isAnonymous = false;
              });
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Donner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: AppColors.secondary, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Chacun donne comme il l\'a résolu en son cœur, sans tristesse ni contrainte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                  const Text(
                    '— 2 Corinthiens 9:7',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Montant rapide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () => _selectAmount(amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${amount.toInt()} FC',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Montant personnalisé',
                prefixIcon: Icon(Icons.monetization_on),
                suffixText: 'FC',
              ),
              onChanged: (v) => setState(() => _selectedAmount = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 20),
            const Text('Objet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _purpose,
              decoration: const InputDecoration(
                labelText: 'Sélectionner l\'objet',
                prefixIcon: Icon(Icons.category),
              ),
              items: _purposes.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)),
              ).toList(),
              onChanged: (v) => setState(() => _purpose = v!),
            ),
            const SizedBox(height: 20),
            const Text('Méthode de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Sélectionner la méthode',
                prefixIcon: Icon(Icons.payment),
              ),
              items: _paymentMethods.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)),
              ).toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Don anonyme'),
              subtitle: const Text('Votre nom ne sera pas affiché'),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
              activeColor: AppColors.secondary,
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isAnonymous) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Votre nom (optionnel)',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone (optionnel)',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _selectedAmount > 0 ? 'Donner ${_selectedAmount.toInt()} FC' : 'Confirmer le don',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
