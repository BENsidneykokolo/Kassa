import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/vendor.dart';
import '../../database/database_helper.dart';

class VendorAuthScreen extends ConsumerStatefulWidget {
  const VendorAuthScreen({super.key});

  @override
  ConsumerState<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen>
    with SingleTickerProviderStateMixin {
  Vendor? _selectedVendor;
  String _pin = '';
  bool _showPinEntry = false;
  bool _pinError = false;
  bool _isFirstTime = false;
  String _confirmPin = '';
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      floatingActionButton: (!_showPinEntry)
          ? FloatingActionButton.extended(
              onPressed: () => _showAddVendorDialog(),
              backgroundColor: AppColors.primary,
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
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          const Text('Yabisso Analytics',
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
          const Text('Qui etes-vous ?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Selectionnez votre profil', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
                        const Text('Aucun vendeur enregistre', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Ajoutez un vendeur pour commencer', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddVendorDialog(),
                            icon: const Icon(Icons.person_add, size: 20),
                            label: const Text('Creer un vendeur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                    crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15,
                  ),
                  itemCount: vendors.length,
                  itemBuilder: (context, index) => _buildVendorCard(vendors[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF6A1B9A'));
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
            Text(vendor.role, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: vendor.pinHash != null ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vendor.pinHash != null ? 'PIN configure' : 'Premiere connexion',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
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
    final color = Color(int.parse(vendor.color?.replaceFirst('#', '0xFF') ?? '0xFF6A1B9A'));
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
              radius: 36, backgroundColor: color,
              child: Text(
                vendor.initials ?? vendor.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(vendor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(isFirstTime ? 'Creez votre PIN a 4 chiffres' : 'Entrez votre PIN',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            if (_isFirstTime && _confirmPin.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Confirmez votre PIN', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
            const SizedBox(height: 32),
            _buildPinDots(isFirstTime),
            if (_pinError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isFirstTime ? 'Les PIN ne correspondent pas' : 'PIN incorrect, reessayez',
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),
            const SizedBox(height: 32),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(bool isFirstTime) {
    final displayPin = _confirmPin.isNotEmpty ? _confirmPin : _pin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < displayPin.length;
        return Container(
          width: 16, height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 56);
              return Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  width: 72, height: 56,
                  child: ElevatedButton(
                    onPressed: () => _onNumpadTap(key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: key == '⌫' ? Colors.grey[200] : AppColors.white,
                      foregroundColor: key == '⌫' ? AppColors.error : AppColors.textDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: key == '⌫'
                        ? const Icon(Icons.backspace_outlined)
                        : Text(key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _onNumpadTap(String key) {
    if (key == '⌫') {
      setState(() {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _pin = _pin.substring(0, _pin.length - 1);
        }
        _pinError = false;
      });
      return;
    }

    final currentPin = _confirmPin.isNotEmpty ? _confirmPin : _pin;
    if (currentPin.length >= 4) return;

    setState(() {
      if (_confirmPin.isNotEmpty) {
        _confirmPin += key;
      } else {
        _pin += key;
      }
      _pinError = false;
    });

    if (currentPin.length + 1 == 4) {
      _validatePin();
    }
  }

  Future<void> _validatePin() async {
    final vendor = _selectedVendor!;
    final isFirstTime = vendor.pinHash == null;

    if (isFirstTime) {
      if (_confirmPin.isEmpty) {
        setState(() => _confirmPin = _pin);
        setState(() { _pin = ''; _isFirstTime = true; });
        return;
      }
      if (_pin != _confirmPin) {
        setState(() { _pinError = true; _pin = ''; _confirmPin = ''; });
        _shakeController.forward(from: 0);
        return;
      }
      final hash = BCrypt.hashpw(_pin, BCrypt.gensalt());
      final updatedVendor = Vendor(
        id: vendor.id, name: vendor.name, role: vendor.role,
        pinHash: hash, color: vendor.color, initials: vendor.initials,
        employeeId: vendor.employeeId, createdAt: vendor.createdAt,
      );
      await DatabaseHelper.instance.updateVendor(updatedVendor);
      _enterApp(vendor);
    } else {
      if (!BCrypt.checkpw(_pin, vendor.pinHash!)) {
        setState(() { _pinError = true; _pin = ''; });
        _shakeController.forward(from: 0);
        return;
      }
      _enterApp(vendor);
    }
  }

  void _enterApp(Vendor vendor) async {
    ref.read(currentVendorProvider.notifier).state = vendor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_vendor_id', vendor.id);
    await prefs.setString('current_vendor_name', vendor.name);
    if (mounted) context.go('/');
  }

  void _selectVendor(Vendor vendor) {
    setState(() {
      _selectedVendor = vendor;
      _showPinEntry = true;
      _pin = '';
      _confirmPin = '';
      _pinError = false;
      _isFirstTime = false;
    });
  }

  void _showAddVendorDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Vendeur');
    String selectedColor = '#6A1B9A';

    final colors = ['#6A1B9A', '#00BCD4', '#4CAF50', '#FF9800', '#E24B4A', '#2196F3', '#9C27B0', '#795548'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un vendeur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nom du vendeur',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    hintText: 'Role (ex: Vendeur, Gerant)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Couleur', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((c) {
                    final isSelected = c == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)]
                              : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final vendor = Vendor(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  role: roleController.text.trim(),
                  color: selectedColor,
                  initials: name.split(' ').where((n) => n.isNotEmpty).map((n) => n[0].toUpperCase()).join('').substring(0, 2.clamp(0, name.length)),
                  createdAt: DateTime.now().toIso8601String(),
                );
                await DatabaseHelper.instance.insertVendor(vendor);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(vendorsProvider);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
