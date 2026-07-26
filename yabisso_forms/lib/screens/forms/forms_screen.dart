import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_template.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  String _searchQuery = '';
  String _filterType = 'tous';
  List<FormTemplate> _templates = [];
  bool _loading = true;

  final Map<String, String> _typeLabels = {
    'tous': 'Tous',
    'feedback': 'Feedback',
    'commande': 'Commande',
    'inscription': 'Inscription',
    'enquete': 'Enquête',
    'autre': 'Autre',
  };

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final templates = await db.getAllFormTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _loading = false;
      });
    }
  }

  List<FormTemplate> get _filteredTemplates {
    return _templates.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesType = _filterType == 'tous' || t.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Formulaires'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTemplates.isEmpty
                    ? _buildEmptyState()
                    : _buildFormsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/forms/add'),
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher un formulaire...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _typeLabels.entries.map((entry) {
          final isSelected = _filterType == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) => setState(() => _filterType = entry.key),
              selectedColor: AppColors.primaryOrange,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dynamic_form, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun formulaire trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier formulaire dynamique',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/forms/add'),
            icon: const Icon(Icons.add),
            label: const Text('Créer un formulaire'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormsList() {
    final filtered = _filteredTemplates;
    return RefreshIndicator(
      onRefresh: _loadForms,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final template = filtered[index];
          return _buildFormCard(template);
        },
      ),
    );
  }

  Widget _buildFormCard(FormTemplate template) {
    return Dismissible(
      key: Key('form_${template.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer le formulaire ?'),
            content: const Text('Cette action est irréversible.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await DatabaseHelper.instance.deleteFormTemplate(template.id!);
        _loadForms();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => context.push('/forms/${template.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor(template.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTypeIcon(template.type), color: _getTypeColor(template.type), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getTypeColor(template.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              template.typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(template.type),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${template.responseCount} réponses',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      if (template.description != null && template.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          template.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'feedback':
        return AppColors.primaryBlue;
      case 'commande':
        return AppColors.primaryGreen;
      case 'inscription':
        return AppColors.primaryOrange;
      case 'enquete':
        return const Color(0xFF7C3AED);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'feedback':
        return Icons.feedback;
      case 'commande':
        return Icons.shopping_cart;
      case 'inscription':
        return Icons.how_to_reg;
      case 'enquete':
        return Icons.poll;
      default:
        return Icons.dynamic_form;
    }
  }
}
