import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../domain/enums.dart';
import '../../data/database/crm_database.dart';
import '../providers/crm_providers.dart';
import 'contact_edit_screen.dart';

/// Fiche 360° : c'est l'écran le plus consulté du CRM. Il rassemble tout ce
/// que l'entreprise sait d'un client — coordonnées, affaires en cours,
/// et le fil chronologique unique mêlant appels, visites, achats
/// (remontés automatiquement par Kassa/Facture) et réservations (Booking).
class ContactDetailScreen extends ConsumerWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(crmDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ContactEditScreen(contactId: contactId)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Interaction'),
        onPressed: () => _showLogInteractionSheet(context, ref),
      ),
      body: FutureBuilder<Contact>(
        future: (db.select(db.contacts)..where((t) => t.id.equals(contactId))).getSingle(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final contact = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (contact.companyName != null) Text(contact.companyName!),
                      const SizedBox(height: 8),
                      if (contact.phone != null) _InfoRow(icon: Icons.call, text: contact.phone!),
                      if (contact.whatsappNumber != null)
                        _InfoRow(icon: Icons.chat, text: '${contact.whatsappNumber} (WhatsApp)'),
                      if (contact.email != null) _InfoRow(icon: Icons.email_outlined, text: contact.email!),
                      if (contact.address != null) _InfoRow(icon: Icons.place_outlined, text: contact.address!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Opportunités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              StreamBuilder<List<Opportunity>>(
                stream: (db.select(db.opportunities)
                      ..where((t) => t.contactId.equals(contactId))
                      ..orderBy([(t) => drift.OrderingTerm.desc(t.updatedAt)]))
                    .watch(),
                builder: (context, oppSnap) {
                  final opps = oppSnap.data ?? [];
                  if (opps.isEmpty) return const Text('Aucune opportunité liée.');
                  return Column(
                    children: opps
                        .map((o) => Card(
                              child: ListTile(
                                title: Text(o.title),
                                subtitle: Text(OpportunityStage.values.byName(o.stage).label),
                                trailing: Text('${o.estimatedValue.toStringAsFixed(0)} FCFA'),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              StreamBuilder<List<Interaction>>(
                stream: (db.select(db.interactions)
                      ..where((t) => t.contactId.equals(contactId))
                      ..orderBy([(t) => drift.OrderingTerm.desc(t.occurredAt)]))
                    .watch(),
                builder: (context, intSnap) {
                  final interactions = intSnap.data ?? [];
                  if (interactions.isEmpty) return const Text('Aucune interaction enregistrée.');
                  return Column(
                    children: interactions
                        .map((i) => ListTile(
                              leading: _iconFor(InteractionType.values.byName(i.type)),
                              title: Text(i.summary),
                              subtitle: Text(
                                '${InteractionType.values.byName(i.type).label} · ${_formatDate(i.occurredAt)}',
                              ),
                              dense: true,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogInteractionSheet(BuildContext context, WidgetRef ref) {
    InteractionType selected = InteractionType.appel;
    final summaryCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nouvelle interaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [InteractionType.appel, InteractionType.visite, InteractionType.reunion, InteractionType.note]
                    .map((t) => ChoiceChip(
                          label: Text(t.label),
                          selected: selected == t,
                          onSelected: (_) => setSheetState(() => selected = t),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: summaryCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (summaryCtrl.text.trim().isEmpty) return;
                  await ref.read(crmServiceProvider).logManualInteraction(
                        tenantId: ref.read(currentTenantIdProvider),
                        contactId: contactId,
                        type: selected,
                        summary: summaryCtrl.text.trim(),
                        employeeId: ref.read(currentEmployeeIdProvider),
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon _iconFor(InteractionType type) {
    switch (type) {
      case InteractionType.appel:
        return const Icon(Icons.call, color: Colors.blue);
      case InteractionType.whatsapp:
        return const Icon(Icons.chat, color: Colors.green);
      case InteractionType.sms:
        return const Icon(Icons.sms_outlined, color: Colors.indigo);
      case InteractionType.email:
        return const Icon(Icons.email_outlined, color: Colors.deepPurple);
      case InteractionType.visite:
        return const Icon(Icons.storefront_outlined, color: Colors.brown);
      case InteractionType.reunion:
        return const Icon(Icons.groups_outlined, color: Colors.teal);
      case InteractionType.achat:
        return const Icon(Icons.shopping_bag_outlined, color: Colors.orange);
      case InteractionType.reservation:
        return const Icon(Icons.event_available_outlined, color: Colors.pink);
      case InteractionType.note:
        return const Icon(Icons.sticky_note_2_outlined, color: Colors.grey);
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
