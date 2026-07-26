import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/campaign.dart';
import '../../providers/providers.dart';

class AddCampaignScreen extends ConsumerStatefulWidget {
  const AddCampaignScreen({super.key});

  @override
  ConsumerState<AddCampaignScreen> createState() => _AddCampaignScreenState();
}

class _AddCampaignScreenState extends ConsumerState<AddCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'sms';
  String _selectedSegment = 'tous';
  String _selectedStatus = 'brouillon';
  bool _isLoading = false;

  final List<Map<String, String>> _segments = [
    {'value': 'tous', 'label': 'Tous les clients'},
    {'value': 'nouveaux', 'label': 'Nouveaux clients'},
    {'value': 'fideles', 'label': 'Clients fideles'},
    {'value': 'inactifs', 'label': 'Clients inactifs'},
    {'value': 'gros_acheteurs', 'label': 'Gros acheteurs'},
  ];

  final List<Map<String, String>> _templates = [
    {
      'name': 'Promotion',
      'message': 'Nouvelle promotion! Profitez de {{remise}} sur tous vos achats. Valide jusqu\'au {{date}}. Merci de votre fidelite!'
    },
    {
      'name': 'Bienvenue',
      'message': 'Bienvenue chez {{boutique}}! Merci pour votre premiere visite. Profitez de {{remise}} avec le code {{code}}.'
    },
    {
      'name': 'Anniversaire',
      'message': 'Joyeux anniversaire {{nom}}! En cadeau, profitez de {{remise}} dans notre magasin. Offre valide toute la semaine.'
    },
    {
      'name': 'Rappel',
      'message': 'Bonjour {{nom}}, n\'oubliez pas que votre solde de points est de {{points}} points. Venez les utiliser dans notre magasin!'
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _applyTemplate(String template) {
    final tpl = _templates.firstWhere((t) => t['name'] == template);
    setState(() {
      _messageController.text = tpl['message']!;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final campaign = Campaign(
        id: const Uuid().v4(),
        name: _nameController.text,
        type: _selectedType,
        message: _messageController.text,
        segment: _selectedSegment,
        status: _selectedStatus,
        recipientsCount: 0,
        createdAt: DateTime.now(),
      );

      await ref.read(campaignsProvider.notifier).addCampaign(campaign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campagne creee avec succes')),
        );
        context.go('/campaigns');
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
        title: const Text('Nouvelle campagne'),
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
                        'Informations generales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la campagne',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type de campagne',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'sms',
                            child: Text('SMS'),
                          ),
                          DropdownMenuItem(
                            value: 'whatsapp',
                            child: Text('WhatsApp'),
                          ),
                          DropdownMenuItem(
                            value: 'email',
                            child: Text('Email'),
                          ),
                          DropdownMenuItem(
                            value: 'reseaux_sociaux',
                            child: Text('Reseaux sociaux'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSegment,
                        decoration: const InputDecoration(
                          labelText: 'Segment cible',
                          prefixIcon: Icon(Icons.people),
                        ),
                        items: _segments.map((segment) {
                          return DropdownMenuItem(
                            value: segment['value'],
                            child: Text(segment['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSegment = value!);
                        },
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: _applyTemplate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.article,
                                      size: 16,
                                      color: AppTheme.primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Modeles',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) {
                              return _templates.map((template) {
                                return PopupMenuItem<String>(
                                  value: template['name'],
                                  child: Text(template['name']!),
                                );
                              }).toList();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Ecrivez votre message ici...\n\nVariables: {{nom}}, {{boutique}}, {{remise}}, {{code}}, {{date}}, {{points}}',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_messageController.text.length} caracteres',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
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
                        'Programmation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'brouillon',
                            child: Text('Brouillon'),
                          ),
                          DropdownMenuItem(
                            value: 'programme',
                            child: Text('Programmer l\'envoi'),
                          ),
                          DropdownMenuItem(
                            value: 'envoye',
                            child: Text('Envoyer maintenant'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                        },
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
                      : const Text('Creer la campagne'),
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
