import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_theme.dart';
import '../../services/database_helper.dart';
import '../../providers/providers.dart';

class ManagerNotesScreen extends ConsumerStatefulWidget {
  const ManagerNotesScreen({super.key});

  @override
  ConsumerState<ManagerNotesScreen> createState() => _ManagerNotesScreenState();
}

class _ManagerNotesScreenState extends ConsumerState<ManagerNotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  List<Map<String, dynamic>> _employees = [];
  String _searchQuery = '';
  String _sentimentFilter = 'Tous';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedEmployeeId;
  String? _selectedCategory;
  String? _selectedSentiment;

  static const List<String> _categories = [
    'Général',
    'Ponctualité',
    'Performance',
    'Relation client',
    'Autre',
  ];

  static const List<String> _sentiments = [
    'Positif',
    'Neutre',
    'Négatif',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notes = await DatabaseHelper.instance.getAll('manager_notes', orderBy: 'created_at DESC');
      final employees = await DatabaseHelper.instance.getAll('employees');
      setState(() {
        _notes = notes;
        _employees = employees;
        _filteredNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _filterNotes() {
    setState(() {
      _filteredNotes = _notes.where((note) {
        final name = (note['employee_name'] ?? '').toString().toLowerCase();
        final noteText = (note['note'] ?? '').toString().toLowerCase();
        final sentiment = (note['sentiment'] ?? '').toString();

        final matchesSearch = _searchQuery.isEmpty ||
            name.contains(_searchQuery.toLowerCase()) ||
            noteText.contains(_searchQuery.toLowerCase());

        final matchesSentiment = _sentimentFilter == 'Tous' ||
            sentiment.toLowerCase() == _sentimentFilter.toLowerCase();

        return matchesSearch && matchesSentiment;
      }).toList();
    });
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positif':
        return AppColors.primaryGreen;
      case 'négatif':
      case 'negatif':
        return AppColors.primaryRed;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _addNote() async {
    if (_selectedEmployeeId == null ||
        _selectedCategory == null ||
        _selectedSentiment == null ||
        _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final admin = ref.read(currentAdminProvider);
    final employee = _employees.firstWhere(
      (e) => e['id'].toString() == _selectedEmployeeId.toString(),
      orElse: () => {'name': ''},
    );

    final noteData = {
      'id': const Uuid().v4(),
      'employee_id': _selectedEmployeeId,
      'employee_name': employee['name'] ?? '',
      'note': _noteController.text.trim(),
      'category': _selectedCategory,
      'sentiment': _selectedSentiment,
      'created_by': admin?.id ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper.instance.insert('manager_notes', noteData);
      await DatabaseHelper.instance.logActivity(
        admin?.id ?? '',
        'Ajout note manager',
        'Note ajoutée pour ${employee['name'] ?? ''}',
      );
      _noteController.clear();
      setState(() {
        _selectedEmployeeId = null;
        _selectedCategory = null;
        _selectedSentiment = null;
      });
      Navigator.of(context).pop();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showAddNoteSheet() {
    _selectedEmployeeId = null;
    _selectedCategory = null;
    _selectedSentiment = null;
    _noteController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nouvelle note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEmployeeId,
                      decoration: InputDecoration(
                        labelText: 'Employé',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _employees.map<DropdownMenuItem<String>>((emp) {
                        return DropdownMenuItem<String>(
                          value: emp['id'].toString(),
                          child: Text(emp['name'] ?? 'Sans nom'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedEmployeeId = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Note',
                        hintText: 'Décrivez votre observation...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSentiment,
                      decoration: InputDecoration(
                        labelText: 'Sentiment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _sentiments.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedSentiment = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _addNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ajouter la note',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notes du manager',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom d\'employé...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _filterNotes();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _filterNotes();
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Tous', 'Positif', 'Neutre', 'Négatif'].map((sentiment) {
                      final isSelected = _sentimentFilter == sentiment;
                      final bgColor = sentiment == 'Positif'
                          ? AppColors.primaryGreen
                          : sentiment == 'Négatif'
                              ? AppColors.primaryRed
                              : sentiment == 'Neutre'
                                  ? Colors.grey
                                  : AppColors.primaryBlue;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            sentiment,
                            style: TextStyle(
                              color: isSelected ? Colors.white : bgColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: bgColor,
                          backgroundColor: bgColor.withValues(alpha: 0.1),
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _sentimentFilter = sentiment);
                            _filterNotes();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _filteredNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune note',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoutez une note pour commencer',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];
                            final sentiment = (note['sentiment'] ?? '').toString();
                            final sentimentColor = _getSentimentColor(sentiment);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: sentimentColor.withValues(alpha: 0.1),
                                          child: Icon(Icons.person, color: sentimentColor, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note['employee_name'] ?? 'Employé inconnu',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(note['created_at']),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: sentimentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            sentiment,
                                            style: TextStyle(
                                              color: sentimentColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        note['category'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      note['note'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
