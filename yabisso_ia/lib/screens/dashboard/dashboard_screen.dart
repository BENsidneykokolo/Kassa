import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/ai_model_service.dart';
import '../chat/chat_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _userName = 'Utilisateur';
  String _activeModelName = 'Aucun modèle';
  bool _noModel = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadActiveModel();
    _generateInsights();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? 'Utilisateur');
  }

  Future<void> _loadActiveModel() async {
    final model = await AiModelService.instance.getActiveModel();
    if (mounted) {
      setState(() {
        if (model != null) {
          _activeModelName = model['name'] as String;
          _noModel = false;
        } else {
          _activeModelName = 'Aucun modèle sélectionné';
          _noModel = true;
        }
      });
    }
  }

  Future<void> _generateInsights() async {
    final db = DatabaseHelper.instance;
    final existing = await db.getAllInsights();
    if (existing.isNotEmpty) return;
    final insights = [
      {'type': 'tendance', 'title': 'Ventes en hausse', 'description': 'Vos ventes ont augmente de 15% cette semaine par rapport a la semaine derniere.'},
      {'type': 'recommandation', 'title': 'Optimisez votre stock', 'description': '3 produits sont en rupture de stock. Reapprovisionnez pour eviter les pertes de ventes.'},
      {'type': 'alerte', 'title': 'Stock faible', 'description': 'Le produit "Produit A" a只剩5 unites en stock.'},
      {'type': 'prediction', 'title': 'Prediction ventes', 'description': 'Base sur vos donnees, vous devriez realiser 2.5M FCFA de ventes ce mois-ci.'},
    ];
    for (final i in insights) {
      await db.insertInsight({...i, 'is_read': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          const ChatScreen(),
          const InsightsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Parametres'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour, $_userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Votre assistant IA est pret', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ])),
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: AppColors.primaryPurple)),
            ]),
            const SizedBox(height: 24),
            // Active model banner
            GestureDetector(
              onTap: () async {
                await context.push('/models');
                _loadActiveModel();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _noModel ? AppColors.primaryAmber.withAlpha(25) : AppColors.primaryPurple.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _noModel ? AppColors.primaryAmber.withAlpha(80) : AppColors.primaryPurple.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: _noModel ? AppColors.primaryAmber.withAlpha(40) : AppColors.primaryPurple.withAlpha(30), borderRadius: BorderRadius.circular(8)), child: Icon(_noModel ? Icons.warning_amber_rounded : Icons.auto_awesome, color: _noModel ? AppColors.primaryAmber : AppColors.primaryPurple, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Modèle IA actif', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text(_activeModelName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _noModel ? AppColors.primaryAmber : AppColors.primaryPurple)),
                    ])),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getAllConversations(),
              builder: (context, convSnap) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.getAllInsights(),
                  builder: (context, insSnap) {
                    final convs = convSnap.data ?? [];
                    final insights = insSnap.data ?? [];
                    final unread = insights.where((i) => i['is_read'] == 0).length;
                    return Row(children: [
                      _statCard('Conversations', '${convs.length}', Icons.chat, AppColors.primaryPurple),
                      const SizedBox(width: 12),
                      _statCard('Insights', '${insights.length}', Icons.insights, AppColors.primaryBlue),
                      const SizedBox(width: 12),
                      _statCard('Alertes', '$unread', Icons.warning_amber, AppColors.primaryAmber),
                    ]);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/chat'),
                icon: const Icon(Icons.add_comment, size: 20),
                label: const Text('Nouvelle conversation', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.push('/models');
                  _loadActiveModel();
                },
                icon: const Icon(Icons.smart_toy, size: 20),
                label: const Text('Modèles IA', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryPurple, side: const BorderSide(color: AppColors.primaryPurple), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/insights'),
                icon: const Icon(Icons.insights, size: 20),
                label: const Text('Voir les insights', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryPurple, side: const BorderSide(color: AppColors.primaryPurple), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Conversations recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getAllConversations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final convs = snapshot.data!.take(5).toList();
                if (convs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Aucune conversation')));
                return Column(children: convs.map((c) => _buildConvCard(c)).toList());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ]),
    ));
  }

  Widget _buildConvCard(Map<String, dynamic> conv) {
    return GestureDetector(
      onTap: () => context.push('/chat/${conv['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat, color: AppColors.primaryPurple, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(conv['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (conv['last_message'] != null) Text(conv['last_message'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ])),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ]),
      ),
    );
  }
}
