import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:yabisso_signature/core/theme/app_theme.dart';
import 'package:yabisso_signature/models/vendor.dart';
import 'package:yabisso_signature/providers/providers.dart';

class VendorAuthScreen extends ConsumerStatefulWidget {
  const VendorAuthScreen({super.key});

  @override
  ConsumerState<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends ConsumerState<VendorAuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vendor = Vendor(
        id: const Uuid().v4(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        businessName: _businessController.text.isNotEmpty ? _businessController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        createdAt: DateTime.now(),
      );

      await ref.read(vendorsProvider.notifier).addVendor(vendor);
      ref.read(currentVendorProvider.notifier).state = vendor;

      if (mounted) {
        context.go('/');
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

  Future<void> _handleSkip() async {
    final vendor = Vendor(
      id: const Uuid().v4(),
      name: 'Utilisateur',
      email: 'user@yabisso.com',
      phone: '+22500000000',
      createdAt: DateTime.now(),
    );

    ref.read(currentVendorProvider.notifier).state = vendor;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Votre profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Informations du marchand',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ces informations seront utilisees sur vos documents signatures.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telephone *',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _handleSkip,
                child: const Text('Passer pour l\'instant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
