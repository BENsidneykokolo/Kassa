import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _verses = [
    'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse point mais qu\'il ait la vie éternelle. — Jean 3:16',
    'L\'Eternel est mon berger ; je ne manquerai de rien. — Psaume 23:1',
    'Je puis tout par celui qui me fortifie. — Philippiens 4:13',
    'Remerciez en toutes choses, car c\'est là la volonté de Dieu. — 1 Thessaloniciens 5:18',
    'L\'Eternel combattra pour vous, et vous, vous garderez le silence. — Exode 14:14',
    'Confiez-vous en l\'Eternel de tout votre cœur, et ne vous appuyez pas sur votre propre intelligence. — Proverbes 3:5',
    'Il m\'a délivré de tous mes frayeurs, et il a les yeux sur mes ennemis. — Psaume 34:7',
    'Je vous ai aimés comme le Père m\'a aimés : demeurez dans mon amour. — Jean 15:9',
    'Que la paix du Christ, à laquelle vous avez été appelés pour former un seul corps, règne dans vos cœurs. — Colossiens 3:15',
    'Cherchez premièrement le royaume et la justice de Dieu ; et toutes ces choses vous seront données par-dessus. — Matthieu 6:33',
  ];

  static const _sermons = [
    {'title': 'La foi qui déplace', 'speaker': 'Pasteur Mbemba', 'duration': '32 min', 'thumbnail': Icons.play_circle_fill},
    {'title': 'L\'amour inconditionnel', 'speaker': 'Évangéliste Nzinga', 'duration': '28 min', 'thumbnail': Icons.play_circle_fill},
    {'title': 'Le pouvoir de la prière', 'speaker': 'Pasteur Mbemba', 'duration': '45 min', 'thumbnail': Icons.play_circle_fill},
    {'title': 'Guérison et restauration', 'speaker': 'Prophète Kivumu', 'duration': '38 min', 'thumbnail': Icons.play_circle_fill},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verseIndex = DateTime.now().day % _verses.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 80,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  const Icon(Icons.church, color: AppColors.secondary, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Yabisso Eglise',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              background: Container(color: AppColors.primary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_stories, color: AppColors.secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Paroles de Vie',
                            style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _verses[verseIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Derniers Messages',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'Voir tout',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sermons.length,
                    itemBuilder: (context, index) {
                      final sermon = _sermons[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 90,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primaryContainer, AppColors.primary],
                                  ),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Center(
                                  child: Icon(
                                    sermon['thumbnail'] as IconData,
                                    color: AppColors.secondary,
                                    size: 48,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sermon['title'] as String,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sermon['speaker'] as String,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sermon['duration'] as String,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Événements à venir',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'Voir tout',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEventCard(
                  'Culte de dimanche',
                  'Culte principal avec louange et adoration',
                  'Dim. 16 Juin • 09:00',
                  'Salle principale',
                  Icons.church,
                ),
                const SizedBox(height: 8),
                _buildEventCard(
                  'Prières du vendredi',
                  'Soirée de prière et de louange',
                  'Ven. 20 Juin • 18:30',
                  'Salle de prière',
                  Icons.mosque,
                ),
                const SizedBox(height: 8),
                _buildEventCard(
                  'Conférence nationale',
                  'Thème: Le réveil spirituel en Afrique',
                  'Sam. 28 Juin • 08:00',
                  'Auditorium principal',
                  Icons.mic,
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEventCard(String title, String description, String date, String location, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event, color: AppColors.secondary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
