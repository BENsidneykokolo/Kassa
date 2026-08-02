import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:yabisso_crm/yabisso_crm.dart';

void main() {
  final db = CrmDatabase(NativeDatabase.memory()); // fichier réel en prod
  const demoTenantId = 'demo-tenant';

  runApp(
    ProviderScope(
      overrides: [
        crmDatabaseProvider.overrideWithValue(db),
        currentTenantIdProvider.overrideWithValue(demoTenantId),
      ],
      child: const YabissoCrmDemoApp(),
    ),
  );
}

class YabissoCrmDemoApp extends StatelessWidget {
  const YabissoCrmDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yabisso CRM',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ContactListScreen(),
    );
  }
}
