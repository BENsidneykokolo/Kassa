import 'package:uuid/uuid.dart';
import '../models/ai_proposal.dart';
import 'database_helper.dart';
import 'analytics_service.dart';

class AiService {
  static final AiService instance = AiService._init();
  AiService._init();

  final _db = DatabaseHelper.instance;

  Future<void> generateDailyProposals() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await _db.getAll('ai_proposals',
        where: "created_at LIKE ?", whereArgs: ['$today%']);
    if (existing.length >= 5) return;

    final analytics = await AnalyticsService.instance.getFullAnalytics();
    final proposals = await _generateProposalsFromData(analytics);

    final count = 5 - existing.length;
    final now = DateTime.now().toIso8601String();

    for (var i = 0; i < count && i < proposals.length; i++) {
      final p = proposals[i];
      final proposal = AiProposal(
        id: const Uuid().v4(),
        title: p['title']!,
        description: p['description']!,
        expectedImpact: p['expectedImpact']!,
        priority: p['priority']!,
        category: p['category']!,
        createdAt: now,
      );
      await _db.insert('ai_proposals', proposal.toMap());
    }
  }

  Future<List<Map<String, String>>> _generateProposalsFromData(
      Map<String, dynamic> analytics) async {
    final proposals = <Map<String, String>>[];

    final employees = analytics['employees'] as Map<String, dynamic>;
    final sales = analytics['sales'] as Map<String, dynamic>;
    final checkins = analytics['checkins'] as Map<String, dynamic>;
    final candidates = analytics['candidates'] as Map<String, dynamic>;
    final teams = analytics['teams'] as Map<String, dynamic>;

    final activeCount = employees['active'] as int;
    final todayAmount = sales['today_amount'] as int;
    final monthAmount = sales['month_amount'] as int;
    final pendingCheckins = checkins['pending'] as int;
    final notContacted =
        (candidates['not_contacted'] as List).cast<Map<String, dynamic>>();
    final lowPerformers =
        (teams['low_performers'] as List).cast<Map<String, dynamic>>();
    final suggestions =
        (teams['pairing_suggestions'] as List).cast<Map<String, dynamic>>();
    final avgSales = teams['avg_sales'] as int;

    // === HR: Low performers need training ===
    if (lowPerformers.isNotEmpty && lowPerformers.length >= 2) {
      final names = lowPerformers.take(2).map((e) => e['name']).join(' et ');
      proposals.add({
        'title': 'Formation ciblée pour $names',
        'description':
            '${lowPerformers.length} employé(s) performent en dessous de la moyenne (${_fmt(avgSales)} FCFA vs moyenne). '
                'Un programme de mentorat avec les meilleurs vendeurs est recommandé.',
        'expectedImpact':
            'Amélioration de 20-30% des ventes de ces employés en 2 semaines',
        'priority': 'high',
        'category': 'hr',
      });
    }

    // === SALES: Today's revenue is low ===
    if (todayAmount == 0 && activeCount > 0) {
      proposals.add({
        'title': 'Aucune vente aujourd\'hui — action immédiate',
        'description':
            'Aucune vente enregistrée aujourd\'hui avec $activeCount employé(s) actif(s). '
                'Vérifiez si les employés sont sur le terrain et relancez les prospects.',
        'expectedImpact': 'Reprise des ventes dans les 24h',
        'priority': 'high',
        'category': 'sales',
      });
    } else if (todayAmount > 0 && activeCount > 0) {
      final perEmployee = todayAmount ~/ activeCount;
      if (perEmployee < avgSales ~/ 30) {
        proposals.add({
          'title': 'Performance quotidienne sous la moyenne',
          'description':
              'CA du jour: ${_fmt(todayAmount)} FCFA pour $activeCount employé(s) '
                  '(${_fmt(perEmployee)} FCFA/employé). La moyenne mensuelle est de ${_fmt(avgSales ~/ (activeCount > 0 ? activeCount : 1))} FCFA/employé.',
          'expectedImpact':
              'Atteindre la moyenne de ${_fmt(avgSales ~/ (activeCount > 0 ? activeCount : 1))} FCFA/employé/jour',
          'priority': 'medium',
          'category': 'sales',
        });
      }
    }

    // === OPERATIONS: Pending checkins need review ===
    if (pendingCheckins >= 5) {
      proposals.add({
        'title': '$pendingCheckins pointages en attente de validation',
        'description':
            'Il y a $pendingCheckins demandes de pointage en attente. '
                'Un retard de validation peut décourager les employés et fausser les données.',
        'expectedImpact': 'Validation sous 2h = motivation employés +15%',
        'priority': 'high',
        'category': 'operations',
      });
    }

    // === MARKETING: Candidates not contacted ===
    if (notContacted.length >= 3) {
      proposals.add({
        'title': '${notContacted.length} candidats pas encore contactés',
        'description':
            'Des candidats potentiels n\'ont pas été contactés. '
                'Chaque jour sans contact réduit de 30% la chance de conversion.',
        'expectedImpact':
            'Conversion de 2-3 candidats supplémentaires par mois',
        'priority': 'medium',
        'category': 'marketing',
      });
    }

    // === HR: Team pairing suggestions ===
    if (suggestions.isNotEmpty) {
      final s = suggestions.first;
      proposals.add({
        'title': 'Parrainage: ${s['mentor']} → ${s['mentee']}',
        'description': s['reason'] as String,
        'expectedImpact':
            'Le mentorat croisé améliore la performance globale de 15-25%',
        'priority': 'medium',
        'category': 'hr',
      });
    }

    // === FINANCE: Monthly revenue trend ===
    if (monthAmount > 0 && activeCount > 0) {
      final monthlyPerEmployee = monthAmount ~/ activeCount;
      if (monthlyPerEmployee < 50000) {
        proposals.add({
          'title': 'Revenu mensuel faible par employé',
          'description':
              'Le revenu mensuel moyen par employé est de ${_fmt(monthlyPerEmployee)} FCFA. '
                  'Objectif minimum recommandé: 100 000 FCFA/employé/mois.',
          'expectedImpact':
              'Doublement du CA mensuel en optimisant les zones de vente',
          'priority': 'medium',
          'category': 'finance',
        });
      }
    }

    // === OPERATIONS: Employee count vs assignments ===
    final totalAssignments = await _db.count('assignments');
    if (activeCount > 0 && totalAssignments == 0) {
      proposals.add({
        'title': 'Aucune assignation créée',
        'description':
            '$activeCount employé(s) actif(s) mais aucune assignation. '
                'Créez des missions pour structurer le travail.',
        'expectedImpact': 'Productivité +20% avec des objectifs clairs',
        'priority': 'low',
        'category': 'operations',
      });
    }

    // === NEW: Analyse des ventes partagées par les employés ===
    await _analyzeSharedSales(proposals);

    // === NEW: Analyse du démarchage partagé par les employés ===
    await _analyzeSharedProspection(proposals);

    // === If no data-driven proposals, add generic ones ===
    if (proposals.isEmpty) {
      proposals.addAll([
        {
          'title': 'Revue hebdomadaire des performances',
          'description':
              'Planifiez une réunion hebdomadaire pour analyser les ventes et aligner l\'équipe.',
          'expectedImpact': 'Meilleure coordination d\'équipe',
          'priority': 'low',
          'category': 'general',
        },
        {
          'title': 'Mise à jour de la base de données',
          'description':
              'Vérifiez que tous les employés et produits sont correctement enregistrés.',
          'expectedImpact': 'Données fiables pour les décisions',
          'priority': 'low',
          'category': 'operations',
        },
        {
          'title': 'Objectif du mois',
          'description':
              'Définissez un objectif de CA mensuel clair pour chaque employé.',
          'expectedImpact': 'Motivation et orientation de l\'équipe',
          'priority': 'low',
          'category': 'sales',
        },
      ]);
    }

    return proposals;
  }

  Future<void> _analyzeSharedSales(List<Map<String, String>> proposals) async {
    try {
      final reports = await _db.getAll('shared_sales_reports');
      if (reports.isEmpty) return;

      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final thisWeek = now.subtract(const Duration(days: 7)).toIso8601String().substring(0, 10);

      final todayReports = reports.where((r) => (r['date'] as String?)?.startsWith(today) == true).toList();
      final weekReports = reports.where((r) => (r['date'] as String?) != null && (r['date'] as String).compareTo(thisWeek) >= 0).toList();

      int weekTotal = 0;
      for (final r in weekReports) {
        weekTotal += (r['total'] as int?) ?? 0;
      }

      if (todayReports.isEmpty && reports.isNotEmpty) {
        proposals.add({
          'title': 'Aucune vente partagée aujourd\'hui',
          'description':
              '${reports.length} rapport(s) de ventes au total dans le système, '
                  'mais aucun rapport partagé aujourd\'hui. '
                  'Vérifiez que les employés envoient leurs rapports de ventes.',
          'expectedImpact': 'Suivi en temps réel des ventes terrain',
          'priority': 'medium',
          'category': 'sales',
        });
      }

      if (weekTotal > 0 && weekReports.length >= 3) {
        final avgPerReport = weekTotal ~/ weekReports.length;
        proposals.add({
          'title': 'Synthèse ventes: ${_fmt(weekTotal)} FCFA cette semaine',
          'description':
              '${weekReports.length} rapports de ventes cette semaine avec une moyenne de '
                  '${_fmt(avgPerReport)} FCFA par rapport. '
                  'Analysez les tendances pour ajuster la stratégie.',
          'expectedImpact': 'Optimisation des objectifs de vente hebdomadaires',
          'priority': 'low',
          'category': 'sales',
        });
      }
    } catch (_) {}
  }

  Future<void> _analyzeSharedProspection(List<Map<String, String>> proposals) async {
    try {
      final reports = await _db.getAll('shared_prospections_reports');
      if (reports.isEmpty) return;

      int totalVisits = 0;
      int totalInteresses = 0;
      int totalPasInteresses = 0;
      int totalARappeler = 0;

      for (final r in reports) {
        totalVisits += (r['total'] as int?) ?? 0;
        totalInteresses += (r['interesses'] as int?) ?? 0;
        totalPasInteresses += (r['pas_interesses'] as int?) ?? 0;
        totalARappeler += (r['a_rappeler'] as int?) ?? 0;
      }

      final conversionRate = totalVisits > 0
          ? (totalInteresses / totalVisits * 100).toStringAsFixed(0)
          : '0';

      if (totalVisits > 0 && totalInteresses == 0) {
        proposals.add({
          'title': 'Démarchage inefficace: 0 intérêt sur $totalVisits visites',
          'description':
              'Les employés ont visité $totalVisits boutiques mais aucune n\'a été intéressée. '
                  'Révisez le discours de vente ou ciblez d\'autres types de commerces.',
          'expectedImpact': 'Amélioration du taux de conversion de 0% à 15-20%',
          'priority': 'high',
          'category': 'marketing',
        });
      }

      if (totalARappeler >= 5) {
        proposals.add({
          'title': '$totalARappeler prospects à rappeler en attente',
          'description':
              '$totalARappeler boutiques ont demandé à être rappelées. '
                  'Un rappel rapide augmente de 60% la chance de conversion.',
          'expectedImpact': 'Conversion de 3-5 prospects supplémentaires',
          'priority': 'high',
          'category': 'marketing',
        });
      }

      if (reports.isNotEmpty) {
        proposals.add({
          'title': 'Synthèse démarchage: $totalVisits visites, $conversionRate% conversion',
          'description':
              '${reports.length} employé(s) ont partagé leur démarcheage. '
                  'Total: $totalVisits visites, $totalInteresses intéressés, '
                  '$totalPasInteresses pas intéressés, $totalARappeler à rappeler.',
          'expectedImpact': 'Visibilité sur l\'effort commercial terrain',
          'priority': 'low',
          'category': 'marketing',
        });
      }
    } catch (_) {}
  }

  String _fmt(int amount) {
    return amount
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Future<List<AiProposal>> getAllProposals() async {
    final maps =
        await _db.getAll('ai_proposals', orderBy: 'created_at DESC');
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
    final totalEmployees =
        await _db.count('employees', where: 'is_active = 1');
    final totalAssignments = await _db.count('assignments');
    final completedAssignments =
        await _db.count('assignments', where: "status = 'completed'");

    final now = DateTime.now();
    final monthStart =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final monthlySales = await _db.sum('sale_records', 'amount',
        where: 'created_at >= ?', whereArgs: [monthStart]);

    return {
      'totalSales': totalSales,
      'totalCommission': totalCommission,
      'totalEmployees': totalEmployees,
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'monthlySales': monthlySales,
      'conversionRate': totalAssignments > 0
          ? (completedAssignments / totalAssignments * 100).toStringAsFixed(1)
          : '0',
    };
  }
}
