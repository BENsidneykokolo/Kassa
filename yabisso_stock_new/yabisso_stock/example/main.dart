// Exemple minimal pour lancer/tester Yabisso Stock isolément pendant le
// développement dans Antigravity. Dans le monorepo final, ce câblage sera
// fait au niveau de l'app hôte (celle qui combine Kassa + Stock + Hôtel...).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yabisso_stock/yabisso_stock.dart';

void main() {
  final db = StockDatabase(NativeDatabase.memory()); // fichier réel en prod
  const demoTenantId = 'demo-tenant';

  runApp(
    ProviderScope(
      overrides: [
        stockDatabaseProvider.overrideWithValue(db),
        currentTenantIdProvider.overrideWithValue(demoTenantId),
      ],
      child: const YabissoStockDemoApp(),
    ),
  );
}

class YabissoStockDemoApp extends StatelessWidget {
  const YabissoStockDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yabisso Stock',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const StockDashboardScreen(),
    );
  }
}
