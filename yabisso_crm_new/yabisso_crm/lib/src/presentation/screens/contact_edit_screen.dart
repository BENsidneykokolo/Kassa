import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../domain/enums.dart';
import '../providers/crm_providers.dart';

class ContactEditScreen extends ConsumerStatefulWidget {
  final String? contactId;
  const ContactEditScreen({super.key, this.contactId});

  @override
  ConsumerState<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends ConsumerState<ContactEditScreen> {
  ContactType _type = ContactType.particulier;
  ContactSource? _source;
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contactId == null ? 'Nouveau contact' : 'Modifier le contact')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<ContactType>(
            segments: const [
              ButtonSegment(value: ContactType.particulier, label: Text('Particulier')),
              ButtonSegment(value: ContactType.entreprise, label: Text('Entreprise')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nom complet / raison sociale'),
          ),
          if (_type == ContactType.entreprise) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _companyCtrl,
              decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Numéro WhatsApp (si différent)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: 'Adresse'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ContactSource>(
            decoration: const InputDecoration(labelText: 'Comment ce contact vous a connu ?'),
            value: _source,
            items: ContactSource.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) => setState(() => _source = v),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est requis.')),
      );
      return;
    }
    final repo = ref.read(contactRepositoryProvider);
    final tenantId = ref.read(currentTenantIdProvider);

    await repo.upsert(ContactsCompanion.insert(
      id: widget.contactId != null ? drift.Value(widget.contactId!) : const drift.Value.absent(),
      tenantId: tenantId,
      type: _type.name,
      fullName: _nameCtrl.text.trim(),
      companyName: drift.Value(_companyCtrl.text.isEmpty ? null : _companyCtrl.text),
      phone: drift.Value(_phoneCtrl.text.isEmpty ? null : _phoneCtrl.text),
      whatsappNumber: drift.Value(_whatsappCtrl.text.isEmpty ? null : _whatsappCtrl.text),
      email: drift.Value(_emailCtrl.text.isEmpty ? null : _emailCtrl.text),
      address: drift.Value(_addressCtrl.text.isEmpty ? null : _addressCtrl.text),
      source: drift.Value(_source?.name),
    ));

    if (mounted) Navigator.of(context).pop();
  }
}
