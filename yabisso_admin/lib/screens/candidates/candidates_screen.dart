import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class CandidatesScreen extends ConsumerStatefulWidget {
  const CandidatesScreen({super.key});
  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  String _searchQuery = '';
  String _filterContact = 'all';
  String _filterPresentation = 'all';
  String _filterMeeting = 'all';

  static const _contactLabels = {
    'all': 'Tous',
    'not_contacted': 'Pas encore contacté',
    'contacted': 'Déjà contacté',
  };
  static const _presentationLabels = {
    'all': 'Tous',
    'not_attended': 'Pas assisté',
    'attended': 'A assisté',
  };
  static const _meetingLabels = {
    'all': 'Tous',
    'not_come': 'Pas venu',
    'come': 'Est venu',
  };

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidatesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Candidats'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_callback),
            tooltip: 'Relance',
            onPressed: () => context.push('/relance'),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddCandidateDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterSection(),
          Expanded(
            child: candidatesAsync.when(
              data: (candidates) {
                final filtered = _applyFilters(candidates);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'Aucun candidat' : 'Aucun résultat',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(candidatesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildCandidateCard(filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> candidates) {
    return candidates.where((c) {
      if (_searchQuery.isNotEmpty) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        final phone = (c['phone'] ?? '').toString();
        if (!name.contains(_searchQuery.toLowerCase()) && !phone.contains(_searchQuery)) return false;
      }
      if (_filterContact != 'all' && c['contact_status'] != _filterContact) return false;
      if (_filterPresentation != 'all' && c['presentation_status'] != _filterPresentation) return false;
      if (_filterMeeting != 'all' && c['meeting_status'] != _filterMeeting) return false;
      return true;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher un candidat...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterDropdown('Contact', _contactLabels, _filterContact, (v) => setState(() => _filterContact = v!)),
            const SizedBox(width: 8),
            _filterDropdown('Présentation', _presentationLabels, _filterPresentation, (v) => setState(() => _filterPresentation = v!)),
            const SizedBox(width: 8),
            _filterDropdown('Meeting', _meetingLabels, _filterMeeting, (v) => setState(() => _filterMeeting = v!)),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown(String label, Map<String, String> options, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final name = candidate['name'] ?? '';
    final phone = candidate['phone'] ?? '';
    final contactStatus = candidate['contact_status'] ?? 'not_contacted';
    final presStatus = candidate['presentation_status'] ?? 'not_attended';
    final meetingStatus = candidate['meeting_status'] ?? 'not_come';
    final relanceStatus = candidate['relance_status'] ?? 'active';
    final hasCv = candidate['cv_path'] != null && (candidate['cv_path'] as String).isNotEmpty;
    final isRelance = relanceStatus == 'relance';

    return GestureDetector(
      onTap: () => _showCandidateDetail(candidate),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isRelance ? Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.5), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isRelance
                    ? AppColors.primaryAmber.withValues(alpha: 0.1)
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isRelance ? AppColors.primaryAmber : AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          if (hasCv) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.attach_file, size: 14, color: AppColors.primaryBlue),
                          ],
                        ],
                      ),
                      if (phone.isNotEmpty) Text(phone, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (isRelance)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryAmber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('À relancer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryAmber)),
                  )
                else
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusBadge(
                  contactStatus == 'contacted' ? 'Contacté' : 'Non contacté',
                  contactStatus == 'contacted' ? AppColors.successGreen : AppColors.primaryAmber,
                ),
                const SizedBox(width: 6),
                _statusBadge(
                  presStatus == 'attended' ? 'Présentation OK' : 'Pas de présentation',
                  presStatus == 'attended' ? AppColors.primaryBlue : Colors.grey,
                ),
                const SizedBox(width: 6),
                _statusBadge(
                  meetingStatus == 'come' ? 'Meeting OK' : 'Pas venu',
                  meetingStatus == 'come' ? AppColors.primaryGreen : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddCandidateDialog({Map<String, dynamic>? existing}) {
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final phoneController = TextEditingController(text: existing?['phone'] ?? '');
    final notesController = TextEditingController(text: existing?['notes'] ?? '');
    String contactStatus = existing?['contact_status'] ?? 'not_contacted';
    String presentationStatus = existing?['presentation_status'] ?? 'not_attended';
    String meetingStatus = existing?['meeting_status'] ?? 'not_come';
    String? cvPath = existing?['cv_path'];
    String? cvType = existing?['cv_type'];
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Modifier le candidat' : 'Ajouter un candidat', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusSection('Contact', {
                  'not_contacted': 'Pas encore contacté',
                  'contacted': 'Déjà contacté',
                }, contactStatus, (v) => setModalState(() => contactStatus = v!)),
                const SizedBox(height: 16),
                _buildStatusSection('Présentation', {
                  'not_attended': 'Pas assisté à la présentation',
                  'attended': 'Déjà assisté à la présentation',
                }, presentationStatus, (v) => setModalState(() => presentationStatus = v!)),
                const SizedBox(height: 16),
                _buildStatusSection('Premier meeting', {
                  'not_come': 'N\'est pas venu au premier meeting',
                  'come': 'Est venu au premier meeting',
                }, meetingStatus, (v) => setModalState(() => meetingStatus = v!)),
                const SizedBox(height: 16),
                _buildCvPicker(cvPath, cvType, setModalState, (path, type) {
                  cvPath = path;
                  cvType = type;
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;
                      final db = DatabaseHelper.instance;
                      final now = DateTime.now().toIso8601String();
                      final data = {
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'cv_path': cvPath ?? '',
                        'cv_type': cvType ?? '',
                        'contact_status': contactStatus,
                        'presentation_status': presentationStatus,
                        'meeting_status': meetingStatus,
                        'notes': notesController.text,
                        'updated_at': now,
                      };
                      if (isEdit) {
                        await db.update('candidates', data, existing['id']);
                      } else {
                        data['id'] = const Uuid().v4();
                        data['created_at'] = now;
                        await db.insert('candidates', data);
                      }
                      ref.invalidate(candidatesProvider);
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: Text(isEdit ? 'Modifier' : 'Ajouter'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(String title, Map<String, String> options, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        ...options.entries.map((e) => RadioListTile<String>(
          value: e.key,
          groupValue: currentValue,
          onChanged: onChanged,
          title: Text(e.value, style: const TextStyle(fontSize: 13)),
          activeColor: AppColors.primaryGreen,
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,
        )),
      ],
    );
  }

  Widget _buildCvPicker(String? cvPath, String? cvType, StateSetter setModalState, Function(String, String) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CV (optionnel)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
            );
            if (result != null && result.files.isNotEmpty) {
              setModalState(() {
                onPicked(result.files.first.path ?? '', result.files.first.extension ?? '');
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cvPath != null ? AppColors.primaryGreen.withValues(alpha: 0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cvPath != null ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  cvPath != null ? Icons.check_circle : Icons.upload_file,
                  color: cvPath != null ? AppColors.primaryGreen : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cvPath != null ? 'CV: ${cvPath.split('/').last}' : 'Sélectionner un CV (PDF, PNG, JPEG)',
                    style: TextStyle(
                      fontSize: 13,
                      color: cvPath != null ? AppColors.primaryGreen : Colors.grey[600],
                      fontWeight: cvPath != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (cvPath != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setModalState(() {
                      onPicked('', '');
                    }),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCandidateDetail(Map<String, dynamic> candidate) {
    final name = candidate['name'] ?? '';
    final phone = candidate['phone'] ?? '';
    final contactStatus = candidate['contact_status'] ?? 'not_contacted';
    final presStatus = candidate['presentation_status'] ?? 'not_attended';
    final meetingStatus = candidate['meeting_status'] ?? 'not_come';
    final relanceStatus = candidate['relance_status'] ?? 'active';
    final notes = candidate['notes'] ?? '';
    final hasCv = candidate['cv_path'] != null && (candidate['cv_path'] as String).isNotEmpty;
    final isRelance = relanceStatus == 'relance';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isRelance
                      ? AppColors.primaryAmber.withValues(alpha: 0.1)
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isRelance ? AppColors.primaryAmber : AppColors.primaryGreen,
                        fontWeight: FontWeight.bold, fontSize: 20,
                      )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (phone.isNotEmpty) Text(phone, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (isRelance)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryAmber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Text('À relancer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryAmber)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Call/WhatsApp buttons
              if (phone.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _callCandidate(phone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Appeler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openWhatsApp(phone),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Status cards
              _detailStatusCard('Contact', contactStatus, 'contacted', 'not_contacted', 'Déjà contacté', 'Pas encore contacté'),
              const SizedBox(height: 8),
              _detailStatusCard('Présentation (Live)', presStatus, 'attended', 'not_attended', 'A assisté', 'Pas assisté'),
              const SizedBox(height: 8),
              _detailStatusCard('Premier Meeting', meetingStatus, 'come', 'not_come', 'Est venu', 'N\'est pas venu'),

              // Absent actions (only if not already in relance)
              if (!isRelance) ...[
                const SizedBox(height: 16),
                Text('Marquer comme absent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: presStatus != 'attended' ? () => _markAbsent(candidate, 'presentation') : null,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Absent au Live', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: meetingStatus != 'come' ? () => _markAbsent(candidate, 'meeting') : null,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Absent au Meeting', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryAmber,
                          side: const BorderSide(color: AppColors.primaryAmber),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // CV
              if (hasCv) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('CV: ${(candidate['cv_path'] as String).split('/').last}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ],

              // Notes
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Text(notes, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ),
              ],
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddCandidateDialog(existing: candidate);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final db = DatabaseHelper.instance;
                        final admin = ref.read(currentAdminProvider);
                        await db.delete('candidates', candidate['id']);
                        await db.logActivity(admin?.id, 'candidate_deleted', 'Candidat supprimé: $name');
                        ref.invalidate(candidatesProvider);
                        if (mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailStatusCard(String title, String current, String trueVal, String falseVal, String trueLabel, String falseLabel) {
    final isTrue = current == trueVal;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTrue ? AppColors.successGreen.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isTrue ? Icons.check_circle : Icons.cancel, color: isTrue ? AppColors.successGreen : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Text(isTrue ? trueLabel : falseLabel, style: TextStyle(fontSize: 12, color: isTrue ? AppColors.successGreen : Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> _markAbsent(Map<String, dynamic> candidate, String stage) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();
    final stageLabel = stage == 'presentation' ? 'Live' : 'Premier Meeting';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer l\'absence'),
        content: Text('Marquer ${candidate['name']} comme absent au $stageLabel ?\n\nIl sera déplacé vers l\'écran Relance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final data = {
                'relance_status': 'relance',
                'relance_stage': stage,
                'last_contact_date': now,
                'updated_at': now,
              };
              await db.update('candidates', data, candidate['id']);
              ref.invalidate(candidatesProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${candidate['name']} déplacé vers Relance'),
                    backgroundColor: AppColors.primaryAmber,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAmber, foregroundColor: Colors.white),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _callCandidate(String phone) async {
    final uri = Uri.parse('tel:${Uri.encodeComponent(phone)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'application Téléphone'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      final uri = Uri.parse('https://wa.me/$cleaned');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final webUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleaned');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp non installé'), backgroundColor: Colors.orange),
          );
        }
      }
    }
  }
}
