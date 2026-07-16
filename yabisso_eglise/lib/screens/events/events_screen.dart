import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/event.dart';
import '../../providers/providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _selectedFilter = 'all';
  bool _calendarView = false;

  static const _eventTypes = {
    'all': 'Tous',
    'worship': 'Culte',
    'conference': 'Conférence',
    'prayer': 'Prières',
    'social': 'Social',
  };

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Événements'),
        actions: [
          IconButton(
            icon: Icon(_calendarView ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _calendarView = !_calendarView),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _eventTypes.entries.map((entry) {
                final isSelected = _selectedFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = entry.key),
                    backgroundColor: Colors.white24,
                    selectedColor: AppColors.secondaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (events) {
          final filtered = _selectedFilter == 'all'
              ? events
              : events.where((e) => e.eventType == _selectedFilter).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucun événement', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Appuyez sur + pour ajouter', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final event = filtered[index];
              return _buildEventCard(event);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventCard(ChurchEvent event) {
    final date = DateTime.tryParse(event.startDate);
    final day = date?.day.toString().padLeft(2, '0') ?? '--';
    final month = _getMonth(date?.month ?? 1);
    final typeColors = {
      'worship': AppColors.primary,
      'conference': AppColors.secondary,
      'prayer': AppColors.primaryContainer,
      'social': Colors.teal,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 72,
              decoration: BoxDecoration(
                color: (typeColors[event.eventType] ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: typeColors[event.eventType] ?? AppColors.primary,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: typeColors[event.eventType] ?? AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (typeColors[event.eventType] ?? AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _eventTypes[event.eventType] ?? event.eventType,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: typeColors[event.eventType] ?? AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (event.location != null) ...[
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 2),
                        Text(event.location!, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                        const SizedBox(width: 12),
                      ],
                      if (event.speaker != null) ...[
                        const Icon(Icons.person_outline, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(event.speaker!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month];
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final speakerController = TextEditingController();
    String eventType = 'worship';
    DateTime selectedDate = DateTime.now();

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
                const Text('Nouvel événement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre *')),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: eventType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: _eventTypes.entries.where((e) => e.key != 'all').map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ).toList(),
                  onChanged: (v) => setModalState(() => eventType = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Lieu')),
                const SizedBox(height: 12),
                TextField(controller: speakerController, decoration: const InputDecoration(labelText: 'Orateur')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isNotEmpty) {
                        final event = ChurchEvent(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          description: descController.text.isNotEmpty ? descController.text : null,
                          eventType: eventType,
                          startDate: selectedDate.toIso8601String(),
                          location: locationController.text.isNotEmpty ? locationController.text : null,
                          speaker: speakerController.text.isNotEmpty ? speakerController.text : null,
                          createdAt: DateTime.now().toIso8601String(),
                        );
                        await DatabaseHelper.instance.insertEvent(event);
                        ref.invalidate(upcomingEventsProvider);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Enregistrer'),
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
