import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/document.dart';
import '../../services/currency_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document> _documents = [];
  List<Document> _filteredDocs = [];
  String _searchQuery = '';
  String _selectedType = 'tous';
  String _selectedStatus = 'tous';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loading = true);
    final docs = await DatabaseHelper.instance.getAllDocuments();
    setState(() {
      _documents = docs;
      _filteredDocs = docs;
      _loading = false;
    });
  }

  void _applyFilters() {
    var filtered = List<Document>.from(_documents);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (d.clientName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    if (_selectedType != 'tous') {
      filtered = filtered.where((d) => d.type == _selectedType).toList();
    }
    if (_selectedStatus != 'tous') {
      filtered = filtered.where((d) => d.status == _selectedStatus).toList();
    }
    setState(() => _filteredDocs = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/documents/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                : _filteredDocs.isEmpty
                    ? _buildEmptyState()
                    : _buildDocumentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) { _searchQuery = v; _applyFilters(); },
        decoration: InputDecoration(
          hintText: 'Rechercher un document...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        children: [
          _buildChip('Tous', 'tous', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Facture', 'facture', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Devis', 'devis', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Contrat', 'contrat', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Bon', 'bon', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Reçu', 'recu', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
          _buildChip('Lettre', 'lettre', _selectedType, (v) { _selectedType = v; _applyFilters(); }),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, String groupValue, Function(String) onTap) {
    final selected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textDark)),
        selected: selected,
        onSelected: (_) => onTap(value),
        selectedColor: AppColors.primaryTeal,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        side: BorderSide(color: selected ? AppColors.primaryTeal : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucun document trouvé', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push('/documents/add'),
            icon: const Icon(Icons.add),
            label: const Text('Créer un document'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredDocs.length,
        itemBuilder: (context, index) => _buildDocumentCard(_filteredDocs[index]),
      ),
    );
  }

  Widget _buildDocumentCard(Document doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description, color: AppColors.primaryTeal, size: 24),
        ),
        title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusBadge(doc.typeLabel, AppColors.primaryTeal),
                const SizedBox(width: 8),
                _buildStatusBadge(doc.statusLabel, _getStatusColor(doc.status)),
              ],
            ),
            if (doc.clientName != null && doc.clientName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(doc.clientName!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
        trailing: doc.amount != null
            ? Text(CurrencyService.fmtPrice(doc.amount!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryTeal))
            : null,
        onTap: () => context.push('/documents/${doc.id}'),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'brouillon': return const Color(0xFFF5A623);
      case 'finalise': return const Color(0xFF4CAF50);
      case 'archive': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
