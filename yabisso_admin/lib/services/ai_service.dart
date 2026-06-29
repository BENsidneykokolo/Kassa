import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/ai_proposal.dart';
import 'database_helper.dart';

class AiService {
  static final AiService instance = AiService._init();
  AiService._init();

  final _db = DatabaseHelper.instance;
  final _random = Random();

  static const _proposalTemplates = [
    {
      'title': 'Campagne de recrutement ciblée',
      'description': 'Lancer une campagne de recrutement sur les réseaux sociaux pour attirer des commerciaux dans la zone de Douala. Cibler les jeunes de 20-30 ans avec expérience en vente.',
      'expectedImpact': 'Augmentation de 30% de l\'équipe commerciale en 2 semaines',
      'priority': 'high',
      'category': 'hr',
    },
    {
      'title': 'Programme de fidélisation clients',
      'description': 'Implémenter un système de points de fidélité pour les boutiques partenaires. Les clients accumulent des points à chaque abonnement acheté.',
      'expectedImpact': 'Augmentation de 15% du taux de rétention des clients',
      'priority': 'high',
      'category': 'marketing',
    },
    {
      'title': 'Optimisation des zones de vente',
      'description': 'Analyser les données de vente pour identifier les zones sous-exploitées et redéployer les commerciaux dans ces secteurs.',
      'expectedImpact': 'Couverture de 20% de nouvelles zones en 1 mois',
      'priority': 'medium',
      'category': 'sales',
    },
    {
      'title': 'Formation accélérée nouveaux employés',
      'description': 'Créer un programme de formation de 3 jours pour les nouveaux employés couvrant les techniques de vente, la connaissance du produit et le service client.',
      'expectedImpact': 'Réduction de 40% du temps d\'intégration',
      'priority': 'medium',
      'category': 'hr',
    },
    {
      'title': 'Promotion saisonnière',
      'description': 'Lancer une promotion de -20% sur tous les abonnements pendant la période de fêtes pour stimuler les ventes.',
      'expectedImpact': 'Hausse de 25% du chiffre d\'affaires mensuel',
      'priority': 'high',
      'category': 'marketing',
    },
    {
      'title': 'Système de commission amélioré',
      'description': 'Revoir la structure des commissions pour récompenser davantage les meilleurs vendeurs et motiver l\'ensemble de l\'équipe.',
      'expectedImpact': 'Augmentation de 20% de la productivité moyenne',
      'priority': 'medium',
      'category': 'finance',
    },
    {
      'title': 'Expansion géographique',
      'description': 'Étendre les activités dans les villes secondaires du Cameroun : Bafoussam, Garoua, Maroua. Recruter des correspondants locaux.',
      'expectedImpact': 'Nouveau marché de 500+ clients potentiels',
      'priority': 'low',
      'category': 'operations',
    },
    {
      'title': 'Application mobile améliorée',
      'description': 'Ajouter des fonctionnalités de paiement mobile et de suivi en temps réel des abonnements dans l\'application.',
      'expectedImpact': 'Amélioration de 35% de l\'expérience utilisateur',
      'priority': 'medium',
      'category': 'operations',
    },
    {
      'title': 'Partenariat stratégique',
      'description': 'Développer des partenariats avec des opérateurs télécoms pour offrir des forfaits data inclus avec les abonnements.',
      'expectedImpact': 'Attractivité accrue de 40% pour les nouveaux clients',
      'priority': 'high',
      'category': 'marketing',
    },
    {
      'title': 'Audit des performances',
      'description': 'Réaliser un audit complet des performances de chaque équipe et identifier les axes d\'amélioration prioritaires.',
      'expectedImpact': 'Optimisation des processus internes de 25%',
      'priority': 'low',
      'category': 'general',
    },
  ];

  Future<void> generateDailyProposals() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await _db.getAll('ai_proposals',
      where: "created_at LIKE ?", whereArgs: ['$today%']);
    if (existing.length >= 3) return;

    final count = 3 - existing.length;
    final available = List.from(_proposalTemplates)..shuffle(_random);
    final now = DateTime.now().toIso8601String();

    for (var i = 0; i < count && i < available.length; i++) {
      final template = available[i];
      final proposal = AiProposal(
        id: const Uuid().v4(),
        title: template['title']!,
        description: template['description']!,
        expectedImpact: template['expectedImpact']!,
        priority: template['priority']!,
        category: template['category']!,
        createdAt: now,
      );
      await _db.insert('ai_proposals', proposal.toMap());
    }
  }

  Future<List<AiProposal>> getAllProposals() async {
    final maps = await _db.getAll('ai_proposals', orderBy: 'created_at DESC');
    return maps.map((m) => AiProposal.fromMap(m)).toList();
  }

  Future<List<AiProposal>> getPendingProposals() async {
    final maps = await _db.getAll('ai_proposals',
      where: "status = 'pending'", orderBy: 'created_at DESC');
    return maps.map((m) => AiProposal.fromMap(m)).toList();
  }

  Future<void> approveProposal(String id, String reviewedBy) async {
    await _db.update('ai_proposals', {
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
      'reviewed_by': reviewedBy,
    }, id);
  }

  Future<void> rejectProposal(String id, String reviewedBy) async {
    await _db.update('ai_proposals', {
      'status': 'rejected',
      'reviewed_at': DateTime.now().toIso8601String(),
      'reviewed_by': reviewedBy,
    }, id);
  }

  Future<Map<String, dynamic>> getMarketingMetrics() async {
    final totalSales = await _db.sum('sale_records', 'amount');
    final totalCommission = await _db.sum('sale_records', 'commission');
    final totalEmployees = await _db.count('employees', where: 'is_active = 1');
    final totalAssignments = await _db.count('assignments');
    final completedAssignments = await _db.count('assignments', where: "status = 'completed'");

    final now = DateTime.now();
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final monthlySales = await _db.sum('sale_records', 'amount',
      where: 'created_at >= ?', whereArgs: [monthStart]);

    return {
      'totalSales': totalSales,
      'totalCommission': totalCommission,
      'totalEmployees': totalEmployees,
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'monthlySales': monthlySales,
      'conversionRate': totalAssignments > 0 ? (completedAssignments / totalAssignments * 100).toStringAsFixed(1) : '0',
    };
  }
}
