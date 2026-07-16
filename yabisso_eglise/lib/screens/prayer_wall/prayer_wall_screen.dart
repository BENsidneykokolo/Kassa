import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../providers/providers.dart';

class PrayerWallScreen extends ConsumerStatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  ConsumerState<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends ConsumerState<PrayerWallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _groups = [
    {'name': 'Groupe de prière du matin', 'schedule': 'Lun-Ven 06:00', 'members': 24, 'leader': 'Soeur Grace'},
    {'name': 'Intercession nationale', 'schedule': 'Mer 18:00', 'members': 45, 'leader': 'Pasteur Mbemba'},
    {'name': 'Jeunes en prière', 'schedule': 'Sam 07:00', 'members': 32, 'leader': 'Évangéliste Nzinga'},
    {'name': 'Prière des mères', 'schedule': 'Dim 06:30', 'members': 18, 'leader': 'Mama Chantal'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerRequestsAsync = ref.watch(prayerRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Communauté'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Mur de Prière'),
            Tab(text: 'Groupes de Vie'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrayerWall(prayerRequestsAsync),
          _buildGroupsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPrayerDialog(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPrayerWall(AsyncValue<List<Map<String, dynamic>>> prayerAsync) {
    return prayerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Aucune requête de prière', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text('Soyez le premier à partager', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildPrayerCard(request);
          },
        );
      },
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> request) {
    final isAnonymous = (request['is_anonymous'] ?? 0) == 1;
    final createdAt = DateTime.tryParse(request['created_at'] ?? '');
    final timeAgo = createdAt != null ? _getTimeAgo(createdAt) : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(
                    isAnonymous ? Icons.person_off : Icons.person,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous ? 'Anonyme' : (request['author_name'] ?? 'Anonyme'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request['content'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await DatabaseHelper.instance.incrementPrayerCount(request['id']);
                    ref.invalidate(prayerRequestsProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_border, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'J\'ai prié (${request['prayer_count'] ?? 0})',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.share, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups, color: AppColors.secondary, size: 28),
            ),
            title: Text(group['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(group['schedule'] as String, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${group['members']} membres', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showAddPrayerDialog() {
    final contentController = TextEditingController();
    final nameController = TextEditingController();
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nouvelle requête de prière',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Publier anonymement'),
                  value: isAnonymous,
                  onChanged: (v) => setModalState(() => isAnonymous = v),
                  activeColor: AppColors.secondary,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isAnonymous) ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Votre nom',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Votre demande de prière',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.mosque),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (contentController.text.isNotEmpty) {
                        final request = {
                          'id': const Uuid().v4(),
                          'author_name': isAnonymous ? null : nameController.text,
                          'is_anonymous': isAnonymous ? 1 : 0,
                          'content': contentController.text,
                          'prayer_count': 0,
                          'is_active': 1,
                          'created_at': DateTime.now().toIso8601String(),
                        };
                        await DatabaseHelper.instance.insertPrayerRequest(request);
                        ref.invalidate(prayerRequestsProvider);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Publier'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
