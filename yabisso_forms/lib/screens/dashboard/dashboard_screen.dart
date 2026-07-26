import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/form_template.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  String _userName = 'Utilisateur';
  int _formCount = 0;
  int _totalResponses = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? prefs.getString('current_vendor_name') ?? 'Utilisateur';
    final db = DatabaseHelper.instance;
    final templates = await db.getAllFormTemplates();
    int totalResponses = 0;
    for (final t in templates) {
      totalResponses += t.responseCount;
    }
    if (mounted) {
      setState(() {
        _userName = name;
        _formCount = templates.length;
        _totalResponses = totalResponses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardContent(),
          _buildFormsList(),
          _buildSettingsPlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/settings');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.dynamic_form), label: 'Formulaires'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentForms(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryOrange,
          child: Text(
            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              _userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.dynamic_form,
            label: 'Formulaires',
            value: _formCount.toString(),
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.question_answer,
            label: 'Réponses',
            value: _totalResponses.toString(),
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                label: 'Nouveau formulaire',
                onTap: () => context.push('/forms/add'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.list_alt,
                label: 'Voir réponses',
                onTap: () => context.push('/forms'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primaryOrange),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentForms() {
    final db = DatabaseHelper.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Formulaires récents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Voir tout', style: TextStyle(color: AppColors.primaryOrange)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<FormTemplate>>(
          future: db.getAllFormTemplates(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final templates = snapshot.data!;
            if (templates.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.dynamic_form, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('Aucun formulaire', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Créez votre premier formulaire', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    ],
                  ),
                ),
              );
            }
            final recent = templates.take(3).toList();
            return Column(
              children: recent.map((t) => _buildFormListItem(t)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormListItem(FormTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.dynamic_form, color: AppColors.primaryOrange),
        ),
        title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${template.typeLabel} • ${template.responseCount} réponses',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/forms/${template.id}'),
      ),
    );
  }

  Widget _buildFormsList() {
    return const FormsContent();
  }

  Widget _buildSettingsPlaceholder() {
    return const Center(child: Text('Paramètres'));
  }
}

class FormsContent extends StatefulWidget {
  const FormsContent({super.key});

  @override
  State<FormsContent> createState() => _FormsContentState();
}

class _FormsContentState extends State<FormsContent> {
  @override
  Widget build(BuildContext context) {
    return const FormsScreen();
  }
}
