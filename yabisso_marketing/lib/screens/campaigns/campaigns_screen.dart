import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  String _selectedFilter = 'tous';

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campagnes'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: _selectedFilter == 'tous',
                  onTap: () => setState(() => _selectedFilter = 'tous'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Brouillons',
                  isSelected: _selectedFilter == 'brouillon',
                  onTap: () => setState(() => _selectedFilter = 'brouillon'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Envoyes',
                  isSelected: _selectedFilter == 'envoye',
                  onTap: () => setState(() => _selectedFilter = 'envoye'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Programmes',
                  isSelected: _selectedFilter == 'programme',
                  onTap: () => setState(() => _selectedFilter = 'programme'),
                ),
              ],
            ),
          ),
          Expanded(
            child: campaigns.when(
              data: (list) {
                final filtered = _selectedFilter == 'tous'
                    ? list
                    : list.where((c) => c.status == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign,
                            size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune campagne',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Creez votre premiere campagne',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/campaigns/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Creer une campagne'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final campaign = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            _getCampaignIcon(campaign.type),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          campaign.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(campaign.typeLabel),
                            const SizedBox(height: 4),
                            Text(
                              campaign.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Modifier'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Supprimer'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              ref
                                  .read(campaignsProvider.notifier)
                                  .deleteCampaign(campaign.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/campaigns/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCampaignIcon(String type) {
    switch (type) {
      case 'sms':
        return Icons.sms;
      case 'whatsapp':
        return Icons.chat;
      case 'email':
        return Icons.email;
      case 'reseaux_sociaux':
        return Icons.public;
      default:
        return Icons.campaign;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
