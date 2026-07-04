import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class RelanceScreen extends ConsumerStatefulWidget {
  const RelanceScreen({super.key});
  @override
  ConsumerState<RelanceScreen> createState() => _RelanceScreenState();
}

class _RelanceScreenState extends ConsumerState<RelanceScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidatesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relance'),
        backgroundColor: AppColors.primaryAmber,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: candidatesAsync.when(
              data: (candidates) {
                final relanceList = candidates.where((c) {
                  if (c['relance_status'] != 'relance') return false;
                  if (_searchQuery.isNotEmpty) {
                    final name = (c['name'] ?? '').toString().toLowerCase();
                    final phone = (c['phone'] ?? '').toString();
                    if (!name.contains(_searchQuery.toLowerCase()) && !phone.contains(_searchQuery)) return false;
                  }
                  return true;
                }).toList();

                if (relanceList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'Aucun candidat à relancer' : 'Aucun résultat',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Les candidats absents apparaîtront ici',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(candidatesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: relanceList.length,
                    itemBuilder: (ctx, i) => _buildRelanceCard(relanceList[i]),
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

  Widget _buildRelanceCard(Map<String, dynamic> candidate) {
    final name = candidate['name'] ?? '';
    final phone = candidate['phone'] ?? '';
    final stage = candidate['relance_stage'] ?? 'unknown';
    final lastContact = candidate['last_contact_date'] ?? candidate['updated_at'] ?? '';
    final stageLabel = stage == 'presentation' ? 'Premier Contact (Live)' : stage == 'meeting' ? 'Premier Meeting' : 'Étape inconnue';
    final stageColor = stage == 'presentation' ? AppColors.primaryBlue : AppColors.primaryAmber;

    String dateDisplay = '';
    if (lastContact.isNotEmpty) {
      try {
        final dt = DateTime.parse(lastContact);
        dateDisplay = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {
        dateDisplay = lastContact;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (phone.isNotEmpty) Text(phone, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryAmber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('À relancer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryAmber)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.flag, size: 14, color: stageColor),
              const SizedBox(width: 6),
              Text('Bloqué à: $stageLabel', style: TextStyle(fontSize: 12, color: stageColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (dateDisplay.isNotEmpty) ...[
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(dateDisplay, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: phone.isNotEmpty ? () => _callCandidate(phone) : null,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Appeler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: phone.isNotEmpty ? () => _openWhatsApp(phone) : null,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reintegrateCandidate(candidate, 'presentation'),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Recontacter Live', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reintegrateCandidate(candidate, 'meeting'),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Recontacter Meeting', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAmber,
                    side: const BorderSide(color: AppColors.primaryAmber),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
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

  Future<void> _reintegrateCandidate(Map<String, dynamic> candidate, String targetStage) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();

    final data = {
      'relance_status': 'active',
      'relance_stage': null,
      'last_contact_date': now,
      'updated_at': now,
    };

    if (targetStage == 'presentation') {
      data['presentation_status'] = 'not_attended';
    } else if (targetStage == 'meeting') {
      data['meeting_status'] = 'not_come';
    }

    await db.update('candidates', data, candidate['id']);
    ref.invalidate(candidatesProvider);

    if (mounted) {
      final stageLabel = targetStage == 'presentation' ? 'Premier Contact (Live)' : 'Premier Meeting';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${candidate['name']} réintégré à l\'étape $stageLabel'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}
