import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/crm_database.dart';
import '../../domain/enums.dart';
import '../providers/crm_providers.dart';
import 'contact_detail_screen.dart';

/// Pipeline commercial en vue kanban. Implémenté avec les widgets natifs
/// Flutter `Draggable`/`DragTarget` — pas de dépendance tierce — pour rester
/// simple à maintenir et sans surprise de compatibilité dans le monorepo.
class OpportunityPipelineScreen extends ConsumerWidget {
  const OpportunityPipelineScreen({super.key});

  static const _columns = [
    OpportunityStage.nouveau,
    OpportunityStage.qualifie,
    OpportunityStage.propositionEnvoyee,
    OpportunityStage.negociation,
    OpportunityStage.gagne,
    OpportunityStage.perdu,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(crmDatabaseProvider);
    final tenantId = ref.watch(currentTenantIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pipeline commercial')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle affaire'),
        onPressed: () => _showCreateSheet(context, ref),
      ),
      body: StreamBuilder<List<Opportunity>>(
        stream: (db.select(db.opportunities)..where((t) => t.tenantId.equals(tenantId))).watch(),
        builder: (context, snap) {
          final all = snap.data ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _columns.map((stage) {
              final items = all.where((o) => o.stage == stage.name).toList();
              final total = items.fold<double>(0, (sum, o) => sum + o.estimatedValue);
              return SizedBox(
                width: 260,
                child: DragTarget<Opportunity>(
                  onWillAcceptWithDetails: (details) => details.data.stage != stage.name,
                  onAcceptWithDetails: (details) async {
                    await ref.read(crmServiceProvider).moveStage(
                          opportunityId: details.data.id,
                          newStage: stage,
                          employeeId: ref.read(currentEmployeeIdProvider),
                        );
                  },
                  builder: (context, candidateData, rejectedData) {
                    final highlighted = candidateData.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: highlighted ? Colors.blue.withOpacity(0.06) : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: highlighted ? Colors.blue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stage.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${items.length} affaire(s) · ${total.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              children: items
                                  .map((o) => Draggable<Opportunity>(
                                        data: o,
                                        feedback: Material(
                                          child: SizedBox(width: 240, child: _OpportunityCard(o)),
                                        ),
                                        childWhenDragging: Opacity(opacity: 0.3, child: _OpportunityCard(o)),
                                        child: GestureDetector(
                                          onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ContactDetailScreen(contactId: o.contactId),
                                            ),
                                          ),
                                          child: _OpportunityCard(o),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    final db = ref.read(crmDatabaseProvider);
    final tenantId = ref.read(currentTenantIdProvider);
    String? contactId;
    final titleCtrl = TextEditingController();
    final valueCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: FutureBuilder<List<Contact>>(
          future: (db.select(db.contacts)..where((t) => t.tenantId.equals(tenantId))).get(),
          builder: (context, snap) {
            final contacts = snap.data ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nouvelle opportunité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Contact'),
                  items: contacts
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)))
                      .toList(),
                  onChanged: (v) => contactId = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre de l\'affaire'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valeur estimée (FCFA)'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (contactId == null || titleCtrl.text.trim().isEmpty) return;
                    await ref.read(crmServiceProvider).createOpportunity(
                          tenantId: tenantId,
                          contactId: contactId!,
                          title: titleCtrl.text.trim(),
                          estimatedValue: double.tryParse(valueCtrl.text.replaceAll(',', '.')) ?? 0,
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard(this.opportunity);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opportunity.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${opportunity.estimatedValue.toStringAsFixed(0)} FCFA',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
