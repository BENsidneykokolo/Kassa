import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yabisso_signature/core/theme/app_theme.dart';
import 'package:yabisso_signature/providers/providers.dart';
import 'package:yabisso_signature/services/currency_service.dart';

class SignaturesScreen extends ConsumerStatefulWidget {
  const SignaturesScreen({super.key});

  @override
  ConsumerState<SignaturesScreen> createState() => _SignaturesScreenState();
}

class _SignaturesScreenState extends ConsumerState<SignaturesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredSignaturesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes signatures'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une signature...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              data: (signatures) {
                if (signatures.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.signature, size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune signature trouvée',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/signatures/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer une signature'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: signatures.length,
                  itemBuilder: (context, index) {
                    final sig = signatures[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: sig.signatureType.index == 0
                              ? AppTheme.primaryColor
                              : sig.signatureType.index == 1
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                          child: Icon(
                            sig.signatureType.index == 0
                                ? Icons.draw
                                : sig.signatureType.index == 1
                                    ? Icons.text_fields
                                    : Icons.image,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          sig.documentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sig.signerName),
                            Text(
                              CurrencyService.formatDateTime(sig.createdAt),
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => context.push('/signatures/${sig.id}'),
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
        onPressed: () => context.push('/signatures/add'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
