import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _videos = [
    {'title': 'Culte du dimanche 16 Juin', 'speaker': 'Pasteur Mbemba', 'duration': '1:32:00', 'views': '1.2k'},
    {'title': 'Prières du matin', 'speaker': 'Ministère de prière', 'duration': '45:00', 'views': '856'},
    {'title': 'Baptême - Cérémonie', 'speaker': 'Pasteur Mbemba', 'duration': '2:15:00', 'views': '2.1k'},
    {'title': 'Réveil spirituel Jour 1', 'speaker': 'Prophète Kivumu', 'duration': '1:58:00', 'views': '3.4k'},
  ];

  static const _audios = [
    {'title': 'Louange - Tu es saint', 'speaker': 'Chœur Yabisso', 'duration': '8:32'},
    {'title': 'Prêche: La foi active', 'speaker': 'Pasteur Mbemba', 'duration': '32:15'},
    {'title': 'Adoration - Hallelujah', 'speaker': 'Chœur Yabisso', 'duration': '12:45'},
    {'title': 'Intercession', 'speaker': 'Ministère de prière', 'duration': '25:00'},
    {'title': 'Cantique: Amazing Grace', 'speaker': 'Solo', 'duration': '5:20'},
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Média'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: 'Vidéos'),
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoGrid(),
          _buildAudioList(),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryContainer, AppColors.primary],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill, color: AppColors.secondary, size: 48),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video['duration']!,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title']!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        video['speaker']!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 11, color: Colors.grey[400]),
                          const SizedBox(width: 2),
                          Text(video['views']!, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _audios.length,
            itemBuilder: (context, index) {
              final audio = _audios[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_arrow, color: AppColors.secondary, size: 28),
                  ),
                  title: Text(audio['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(audio['speaker']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  trailing: Text(
                    audio['duration']!,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Louange - Tu es saint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Text('Chœur Yabisso', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: AppColors.secondary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
