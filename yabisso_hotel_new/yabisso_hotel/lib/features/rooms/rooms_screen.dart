import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/room.dart';

/// Gestion des chambres — section 4 du prompt. Vue grille avec cartes
/// colorées selon le statut, recherche et filtres par étage/type.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String _query = '';
  int? _floorFilter;

  @override
  Widget build(BuildContext context) {
    final floors = MockData.rooms.map((r) => r.floor).toSet().toList()..sort();
    final filtered = MockData.rooms.where((r) {
      final matchesQuery = r.number.contains(_query) || r.type.toLowerCase().contains(_query.toLowerCase());
      final matchesFloor = _floorFilter == null || r.floor == _floorFilter;
      return matchesQuery && matchesFloor;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chambres'),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: SyncIndicator())],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher une chambre (numéro, type)',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _FilterChip(label: 'Tous les étages', selected: _floorFilter == null, onTap: () => setState(() => _floorFilter = null)),
                ...floors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: 'Étage $f',
                      selected: _floorFilter == f,
                      onTap: () => setState(() => _floorFilter = f),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) => _RoomCard(room: filtered[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle chambre'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('N° ${room.number}', style: Theme.of(context).textTheme.titleLarge),
              StatusBadge.room(room.status),
            ],
          ),
          const SizedBox(height: 4),
          Text('${room.type} — Étage ${room.floor}', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.bed_rounded, color: AppColors.textSecondary, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${room.pricePerNight.toStringAsFixed(0)} F / nuit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
