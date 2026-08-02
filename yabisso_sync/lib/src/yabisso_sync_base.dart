enum SyncPriority { low, medium, high }
enum ConflictStrategy { lastWriteWins, insertOnly, serverWins }

class YabissoSync {
  void registerTable({
    required dynamic table,
    SyncPriority priority = SyncPriority.medium,
    ConflictStrategy conflictStrategy = ConflictStrategy.lastWriteWins,
  }) {}
}
