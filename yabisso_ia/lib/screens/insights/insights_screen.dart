import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedFilter = 'tous';

  static const Map<String, String> _filterLabels = {
    'tous': 'Tous',
    'tendance': 'Tendance',
    'alerte': 'Alerte',
    'recommandation': 'Recommandation',
    'prediction': 'Prediction',
  };

  static const Map<String, Color> _typeColors = {
    'tendance': AppColors.primaryBlue,
    'alerte': AppColors.primaryRed,
    'recommandation': AppColors.primaryGreen,
    'prediction': AppColors.primaryPurple,
  };

  static const Map<String, IconData> _typeIcons = {
    'tendance': Icons.trending_up,
    'alerte': Icons.warning_amber,
    'recommandation': Icons.lightbulb,
    'prediction': Icons.psychology,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights IA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildInsightsList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterLabels.entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(entry.value, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textDark)),
              selected: isSelected,
              selectedColor: AppColors.primaryPurple,
              backgroundColor: Colors.white,
              side: BorderSide(color: isSelected ? AppColors.primaryPurple : AppColors.border),
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = entry.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _selectedFilter == 'tous'
          ? DatabaseHelper.instance.getAllInsights()
          : DatabaseHelper.instance.getInsightsByType(_selectedFilter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final insights = snapshot.data!;
        if (insights.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insights, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Aucun insight disponible', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 8),
                Text('Les analyses IA apparaîtront ici', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: insights.length,
          itemBuilder: (context, index) => _buildInsightCard(insights[index]),
        );
      },
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    final color = _typeColors[type] ?? AppColors.primaryPurple;
    final icon = _typeIcons[type] ?? Icons.insights;
    final isRead = insight['is_read'] == 1;

    return GestureDetector(
      onTap: () async {
        if (!isRead) {
          await DatabaseHelper.instance.markInsightAsRead(insight['id']);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isRead ? AppColors.border : color.withAlpha(80)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(insight['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isRead ? Colors.grey[700] : AppColors.textDark)),
                      ),
                      if (!isRead)
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight['description'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                    child: Text(_filterLabels[type] ?? type, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
