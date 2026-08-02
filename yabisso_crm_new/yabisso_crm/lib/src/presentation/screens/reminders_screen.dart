import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/crm_providers.dart';
import 'contact_detail_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(dueRemindersProvider);
    final db = ref.watch(crmDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rappels de suivi')),
      body: remindersAsync.when(
        data: (reminders) => reminders.isEmpty
            ? const Center(child: Text('Aucun rappel en attente 🎉'))
            : ListView(
                children: reminders
                    .map((r) => FutureBuilder<Contact>(
                          future: (db.select(db.contacts)..where((t) => t.id.equals(r.contactId)))
                              .getSingle(),
                          builder: (context, snap) {
                            final name = snap.data?.fullName ?? '…';
                            return ListTile(
                              leading: const Icon(Icons.alarm, color: Colors.orange),
                              title: Text(name),
                              subtitle: Text(r.note),
                              trailing: IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                tooltip: 'Marquer comme fait',
                                onPressed: () => ref.read(crmServiceProvider).markReminderDone(r.id),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: r.contactId)),
                              ),
                            );
                          },
                        ))
                    .toList(),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur : $e'),
      ),
    );
  }
}
