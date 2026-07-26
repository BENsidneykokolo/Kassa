import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yabisso_signature/core/theme/app_theme.dart';
import 'package:yabisso_signature/providers/providers.dart';
import 'package:yabisso_signature/services/currency_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final signaturesAsync = ref.watch(signaturesProvider);
    final currentVendor = ref.watch(currentVendorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yabisso Signature'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildDashboard(context, signaturesAsync, currentVendor)
          : _buildSignaturesList(signaturesAsync),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tableau de bord'),
          BottomNavigationBarItem(icon: Icon(Icons.signature), label: 'Signatures'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/signatures/add'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle signature', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AsyncValue signaturesAsync, vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vendor != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        vendor.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vendor.businessName != null)
                            Text(
                              vendor.businessName!,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Statistiques',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          signaturesAsync.when(
            data: (signatures) => Row(
              children: [
                _buildStatCard(
                  context,
                  'Total',
                  '${signatures.length}',
                  Icons.description,
                  AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Signes',
                  '${signatures.where((s) => s.status.index == 1).length}',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Brouillons',
                  '${signatures.where((s) => s.status.index == 0).length}',
                  Icons.edit_note,
                  AppTheme.warningColor,
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
          const SizedBox(height: 24),
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'Nouvelle signature',
                  Icons.draw,
                  AppTheme.primaryColor,
                  () => context.push('/signatures/add'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Toutes les signatures',
                  Icons.list,
                  AppTheme.accentColor,
                  () => context.push('/signatures'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'Signature texte',
                  Icons.text_fields,
                  AppTheme.successColor,
                  () => context.push('/signatures/add'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Parametres',
                  Icons.settings,
                  AppTheme.warningColor,
                  () => context.push('/settings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Dernieres signatures',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          signaturesAsync.when(
            data: (signatures) {
              if (signatures.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.signature, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune signature',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Creez votre premiere signature electronique',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final recent = signatures.take(3).toList();
              return Column(
                children: recent.map((sig) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        sig.signatureType.index == 0 ? Icons.draw
                            : sig.signatureType.index == 1 ? Icons.text_fields
                            : Icons.image,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(sig.documentName),
                    subtitle: Text(sig.signerName),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sig.status.index == 1
                            ? AppTheme.successColor
                            : sig.status.index == 0
                                ? AppTheme.warningColor
                                : AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sig.statusLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () => context.push('/signatures/${sig.id}'),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturesList(AsyncValue signaturesAsync) {
    return signaturesAsync.when(
      data: (signatures) {
        if (signatures.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.signature, size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'Aucune signature',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: signatures.length,
          itemBuilder: (context, index) {
            final sig = signatures[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(
                    sig.signatureType.index == 0 ? Icons.draw
                        : sig.signatureType.index == 1 ? Icons.text_fields
                        : Icons.image,
                    color: Colors.white,
                  ),
                ),
                title: Text(sig.documentName),
                subtitle: Text('${sig.signerName} - ${CurrencyService.formatDateTime(sig.createdAt)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/signatures/${sig.id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
