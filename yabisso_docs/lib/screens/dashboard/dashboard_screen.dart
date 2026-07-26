import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/document.dart';
import '../../models/template.dart';
import '../../services/currency_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  List<Document> _recentDocs = [];
  List<DocTemplate> _templates = [];
  int _docCount = 0;
  int _templateCount = 0;
  int _brouillonCount = 0;
  int _finaliseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final docs = await db.getAllDocuments();
    final templates = await db.getAllTemplates();
    final recent = await db.getRecentDocuments(limit: 5);
    final docCount = await db.getDocumentCount();
    final templateCount = templates.length;
    final brouillonCount = await db.getDocumentCountByType('brouillon');
    final finaliseCount = await db.getDocumentCountByType('finalise');
    if (mounted) {
      setState(() {
        _recentDocs = recent;
        _templates = templates;
        _docCount = docCount;
        _templateCount = templateCount;
        _brouillonCount = docs.where((d) => d.status == 'brouillon').length;
        _finaliseCount = docs.where((d) => d.status == 'finalise').length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardBody(),
      const DocumentsScreenPlaceholder(),
      const TemplatesScreenPlaceholder(),
      const SettingsScreenPlaceholder(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 1) { context.go('/documents'); return; }
          if (i == 2) { context.go('/templates'); return; }
          if (i == 3) { context.go('/settings'); return; }
          setState(() => _currentIndex = i);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Templates'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/documents/add'),
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDashboardBody() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentDocuments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryTeal, Color(0xFF00695C)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bonjour ! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Bienvenue sur Yabisso Docs', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 12),
          Text('$_docCount documents', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Documents', '$_docCount', Icons.description, const Color(0xFF00897B)),
        _buildStatCard('Templates', '$_templateCount', Icons.dashboard, const Color(0xFF378ADD)),
        _buildStatCard('Brouillons', '$_brouillonCount', Icons.edit_note, const Color(0xFFF5A623)),
        _buildStatCard('Finalisés', '$_finaliseCount', Icons.check_circle_outline, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard('Nouveau document', Icons.add_circle_outline, AppColors.primaryTeal, () => context.push('/documents/add'))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard('Templates', Icons.dashboard_outlined, AppColors.primaryBlue, () => context.push('/templates'))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Documents récents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            TextButton(onPressed: () => context.go('/documents'), child: const Text('Voir tout', style: TextStyle(color: AppColors.primaryTeal))),
          ],
        ),
        if (_recentDocs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Aucun document', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text('Créez votre premier document', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
          )
        else
          ..._recentDocs.map((doc) => _buildDocumentTile(doc)),
      ],
    );
  }

  Widget _buildDocumentTile(Document doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.description, color: AppColors.primaryTeal, size: 24),
        ),
        title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${doc.typeLabel} • ${doc.statusLabel}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: doc.amount != null
            ? Text(CurrencyService.fmtPrice(doc.amount!), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryTeal))
            : null,
        onTap: () => context.push('/documents/${doc.id}'),
      ),
    );
  }
}

class DocumentsScreenPlaceholder extends StatelessWidget {
  const DocumentsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Documents')));
  }
}

class TemplatesScreenPlaceholder extends StatelessWidget {
  const TemplatesScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Templates')));
  }
}

class SettingsScreenPlaceholder extends StatelessWidget {
  const SettingsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Paramètres')));
  }
}
