import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/template.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<DocTemplate> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _loading = true);
    final templates = await DatabaseHelper.instance.getAllTemplates();
    setState(() {
      _templates = templates;
      _loading = false;
    });
  }

  void _useTemplate(DocTemplate template) {
    context.push('/documents/add');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "${template.name}" sélectionné'),
        backgroundColor: AppColors.primaryTeal,
        action: SnackBarAction(
          label: 'Ouvrir',
          textColor: Colors.white,
          onPressed: () => context.push('/documents/add'),
        ),
      ),
    );
  }

  void _previewTemplate(DocTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(template.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeBadge(template.type),
                const SizedBox(width: 8),
                Text(template.description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(template.content, style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _useTemplate(template); },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Utiliser ce template', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(_getTypeLabel(type), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'facture': return 'Facture';
      case 'devis': return 'Devis';
      case 'contrat': return 'Contrat';
      case 'bon': return 'Bon';
      case 'recu': return 'Reçu';
      case 'lettre': return 'Lettre';
      default: return 'Autre';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'facture': return AppColors.primaryTeal;
      case 'devis': return AppColors.primaryBlue;
      case 'contrat': return const Color(0xFF7C3AED);
      case 'bon': return AppColors.primaryAmber;
      case 'recu': return const Color(0xFF4CAF50);
      case 'lettre': return const Color(0xFFE91E63);
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'facture': return Icons.receipt;
      case 'devis': return Icons.request_quote;
      case 'contrat': return Icons.gavel;
      case 'bon': return Icons.shopping_cart;
      case 'recu': return Icons.payment;
      case 'lettre': return Icons.mail;
      default: return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
          : _templates.isEmpty
              ? _buildEmptyState()
              : _buildTemplatesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucun template disponible', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _templates.length,
        itemBuilder: (context, index) => _buildTemplateCard(_templates[index]),
      ),
    );
  }

  Widget _buildTemplateCard(DocTemplate template) {
    final color = _getTypeColor(template.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _previewTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getTypeIcon(template.type), color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(template.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    _buildTypeBadge(template.type),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
