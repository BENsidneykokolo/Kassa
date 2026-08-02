import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/crm_database.dart';
import '../../data/repositories/contact_repository.dart';
import '../../application/crm_service.dart';

final crmDatabaseProvider = Provider<CrmDatabase>((ref) {
  throw UnimplementedError(
    'crmDatabaseProvider doit être surchargé au démarrage de l\'app avec '
    'la connexion Drift réelle (voir main.dart).',
  );
});

final currentTenantIdProvider = Provider<String>((ref) {
  throw UnimplementedError('currentTenantIdProvider doit être surchargé.');
});

final currentEmployeeIdProvider = Provider<String?>((ref) => null);

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepository(ref.watch(crmDatabaseProvider));
});

final crmServiceProvider = Provider<CrmService>((ref) {
  return CrmService(ref.watch(crmDatabaseProvider));
});

final allContactsProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(contactRepositoryProvider).watchAll(ref.watch(currentTenantIdProvider));
});

final contactSearchQueryProvider = StateProvider<String>((ref) => '');

final contactSearchResultsProvider = StreamProvider<List<Contact>>((ref) {
  final query = ref.watch(contactSearchQueryProvider);
  final tenantId = ref.watch(currentTenantIdProvider);
  final repo = ref.watch(contactRepositoryProvider);
  return query.isEmpty ? repo.watchAll(tenantId) : repo.search(tenantId, query);
});

final dueRemindersProvider = StreamProvider<List<FollowUpReminder>>((ref) {
  return ref
      .watch(contactRepositoryProvider)
      .watchDueReminders(ref.watch(currentTenantIdProvider));
});
