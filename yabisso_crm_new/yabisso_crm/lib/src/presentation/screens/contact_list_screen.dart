import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/crm_providers.dart';
import 'contact_detail_screen.dart';
import 'opportunity_pipeline_screen.dart';
import 'reminders_screen.dart';
import 'contact_edit_screen.dart';

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(contactSearchResultsProvider);
    final remindersAsync = ref.watch(dueRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yabisso CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_kanban_outlined),
            tooltip: 'Pipeline',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OpportunityPipelineScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher un contact (nom, téléphone…)',
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onChanged: (v) => ref.read(contactSearchQueryProvider.notifier).state = v,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add_alt),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContactEditScreen()),
        ),
      ),
      body: Column(
        children: [
          remindersAsync.maybeWhen(
            data: (reminders) => reminders.isEmpty
                ? const SizedBox.shrink()
                : Material(
                    color: Colors.amber.shade50,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RemindersScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text('${reminders.length} rappel(s) à traiter aujourd\'hui',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: resultsAsync.when(
              data: (contacts) => contacts.isEmpty
                  ? const Center(child: Text('Aucun contact pour l\'instant.'))
                  : ListView.separated(
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = contacts[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(c.fullName.isNotEmpty ? c.fullName[0] : '?')),
                          title: Text(c.fullName),
                          subtitle: Text(c.companyName ?? c.phone ?? ''),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: c.id)),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
            ),
          ),
        ],
      ),
    );
  }
}
