import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../services/currency_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Currency _selectedCurrency = CurrencyService.defaultCurrency;
  String _storeName = 'Yabisso Analytics';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currency = await CurrencyService.getSelectedCurrency();
    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('store_name') ?? 'Yabisso Analytics';
    if (mounted) {
      setState(() {
        _selectedCurrency = currency;
        _storeName = storeName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Ma Boutique'),
            subtitle: Text(_storeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showStoreNameDialog,
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Devise'),
            subtitle: Text(_selectedCurrency.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showCurrencyDialog,
          ),
          const Divider(),
          _buildSectionHeader('Analytique'),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.primary),
            title: const Text('Graphiques'),
            subtitle: const Text('Visualisez vos donnees'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/charts'),
          ),
          ListTile(
            leading: const Icon(Icons.assessment, color: AppColors.accent),
            title: const Text('Rapports'),
            subtitle: const Text('Resume par periode'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reports'),
          ),
          ListTile(
            leading: const Icon(Icons.speed, color: AppColors.warning),
            title: const Text('KPIs'),
            subtitle: const Text('Indicateurs cles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/kpis'),
          ),
          const Divider(),
          _buildSectionHeader('Donnees'),
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.primary),
            title: const Text('Exporter les donnees'),
            subtitle: const Text('Partager un resume'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          const Divider(),
          _buildSectionHeader('A propos'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Conditions d\'utilisation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTerms,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialite'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacy,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Se deconnecter'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la devise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyService.availableCurrencies.length,
            itemBuilder: (context, index) {
              final currency = CurrencyService.availableCurrencies[index];
              return RadioListTile<Currency>(
                title: Text(currency.name),
                subtitle: Text('${currency.symbol} (${currency.code})'),
                value: currency,
                groupValue: _selectedCurrency,
                onChanged: (value) async {
                  if (value != null) {
                    await CurrencyService.setSelectedCurrency(value.code);
                    setState(() => _selectedCurrency = value);
                    if (mounted) Navigator.pop(context);
                  }
                },
                activeColor: AppColors.primary,
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ],
      ),
    );
  }

  void _showStoreNameDialog() {
    final controller = TextEditingController(text: _storeName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nom de la boutique'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nom de votre boutique',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('store_name', name);
                setState(() => _storeName = name);
              }
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalite bientot disponible'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant Yabisso Analytics, vous acceptez les conditions suivantes :\n\n'
            '1. Cette application est destinee a un usage commercial personnel.\n'
            '2. Les donnees sont stockees localement sur votre appareil.\n'
            '3. L\'editeur ne sera pas responsable de perte de donnees.\n'
            '4. L\'utilisation est soumise a un abonnement actif.\n\n'
            'Pour toute question, contactez-nous via WhatsApp.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialite'),
        content: const SingleChildScrollView(
          child: Text(
            'Yabisso Analytics respecte votre vie privee :\n\n'
            '1. Aucune donnee n\'est partagee avec des tiers.\n'
            '2. Toutes les donnees restent sur votre appareil.\n'
            '3. Aucune collecte de donnees personnelles automatique.\n'
            '4. Vous pouvez supprimer vos donnees a tout moment.\n\n'
            'Pour toute question, contactez-nous via WhatsApp.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
