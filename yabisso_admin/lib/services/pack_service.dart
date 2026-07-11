import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';

class PackResult {
  final bool success;
  final String? filePath;
  final String? error;
  final int? recordCount;
  final String? appName;

  PackResult({required this.success, this.filePath, this.error, this.recordCount, this.appName});
}

class PackService {
  static const String packVersion = '1.0.0';
  static const String appIdentifier = 'admin';

  static Future<PackResult> exportPack({String? customPath}) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final tempDir = await getTemporaryDirectory();
      final packId = const Uuid().v4().substring(0, 8);
      final packDir = Directory(p.join(tempDir.path, 'pack_$packId'));
      final dataDir = Directory(p.join(packDir.path, 'data'));
      final filesDir = Directory(p.join(packDir.path, 'files'));

      await dataDir.create(recursive: true);
      await filesDir.create(recursive: true);

      int totalRecords = 0;

      // Export all 26 database tables
      final tables = [
        'admins', 'employees', 'employee_profiles', 'employee_documents',
        'assignments', 'employee_tasks', 'ai_proposals', 'sale_records',
        'settings', 'activity_log', 'checkin_requests', 'shared_sales_reports',
        'shared_prospections_reports', 'candidates', 'prospectives',
        'contact_history', 'leaves', 'objectives', 'rewards', 'sanctions',
        'trainings', 'employee_trainings', 'manager_notes', 'daily_reports',
        'notifications', 'attendance'
      ];

      final db = await dbHelper.database;
      for (final table in tables) {
        try {
          final rows = await db.query(table);
          final file = File(p.join(dataDir.path, '$table.json'));
          await file.writeAsString(jsonEncode(rows));
          totalRecords += rows.length;
        } catch (_) {}
      }

      // Export SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsData = <String, dynamic>{};
      for (final key in prefs.getKeys()) {
        prefsData[key] = prefs.get(key);
      }
      final prefsFile = File(p.join(dataDir.path, 'shared_preferences.json'));
      await prefsFile.writeAsString(jsonEncode(prefsData));

      // Copy local files (CVs, photos, documents, task proofs)
      final docsDir = await getApplicationDocumentsDirectory();
      final fileCategories = {
        'cv_files': 'cv_files',
        'employee_photos': 'employee_photos',
        'employee_documents': 'employee_documents',
        'task_proofs': 'task_proofs',
      };

      for (final entry in fileCategories.entries) {
        final sourceDir = Directory(p.join(docsDir.path, entry.key));
        if (await sourceDir.exists()) {
          final targetDir = Directory(p.join(filesDir.path, entry.value));
          await targetDir.create(recursive: true);
          await for (final entity in sourceDir.list()) {
            if (entity is File) {
              await entity.copy(p.join(targetDir.path, p.basename(entity.path)));
            }
          }
        }
      }

      // Create manifest
      final manifest = {
        'pack_version': packVersion,
        'app': appIdentifier,
        'app_name': 'Admin',
        'created_at': DateTime.now().toIso8601String(),
        'pack_id': packId,
        'tables': tables,
        'total_records': totalRecords,
        'has_files': true,
      };
      final manifestFile = File(p.join(packDir.path, 'manifest.json'));
      await manifestFile.writeAsString(jsonEncode(manifest));

      // Create ZIP archive
      final archive = Archive();
      await _addDirectoryToArchive(archive, packDir.path, packDir.path);

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        return PackResult(success: false, error: 'Erreur lors de la compression ZIP');
      }

      final appDocsDir = await getApplicationDocumentsDirectory();
      final outputDir = customPath ?? p.join(appDocsDir.path, 'packs');
      await Directory(outputDir).create(recursive: true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = p.join(outputDir, 'admin_pack_${packId}_$timestamp.yabissopack');

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(zipData);

      await packDir.delete(recursive: true);

      return PackResult(
        success: true,
        filePath: outputPath,
        recordCount: totalRecords,
        appName: 'Admin',
      );
    } catch (e) {
      return PackResult(success: false, error: e.toString());
    }
  }

  static Future<PackResult> importPack(String packPath) async {
    try {
      final packFile = File(packPath);
      if (!await packFile.exists()) {
        return PackResult(success: false, error: 'Fichier pack introuvable');
      }

      final zipBytes = await packFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(p.join(tempDir.path, 'import_${const Uuid().v4().substring(0, 8)}'));
      await extractDir.create(recursive: true);

      for (final file in archive) {
        final filePath = p.join(extractDir.path, file.name);
        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        return PackResult(success: false, error: 'Pack invalide : manifest.json manquant');
      }
      final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
      final sourceApp = manifest['app'] as String? ?? 'unknown';

      if (sourceApp != appIdentifier) {
        return PackResult(success: false, error: "Ce pack est pour l'app \"${manifest['app_name'] ?? sourceApp}\" pas pour Admin");
      }

      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      int totalRecords = 0;

      final dataDir = Directory(p.join(extractDir.path, 'data'));
      if (await dataDir.exists()) {
        await for (final entity in dataDir.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            final tableName = p.basenameWithoutExtension(entity.path);
            if (tableName == 'shared_preferences') continue;

            try {
              final rows = jsonDecode(await entity.readAsString()) as List<dynamic>;
              for (final row in rows) {
                final map = Map<String, dynamic>.from(row as Map);
                await db.insert(tableName, map,
                    conflictAlgorithm: ConflictAlgorithm.replace);
                totalRecords++;
              }
            } catch (_) {}
          }
        }
      }

      // Import SharedPreferences
      final prefsFile = File(p.join(dataDir.path, 'shared_preferences.json'));
      if (await prefsFile.exists()) {
        final prefsData = jsonDecode(await prefsFile.readAsString()) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        for (final entry in prefsData.entries) {
          final value = entry.value;
          if (value is String) {
            await prefs.setString(entry.key, value);
          } else if (value is bool) {
            await prefs.setBool(entry.key, value);
          } else if (value is int) {
            await prefs.setInt(entry.key, value);
          } else if (value is double) {
            await prefs.setDouble(entry.key, value);
          } else if (value is List) {
            await prefs.setStringList(entry.key, value.cast<String>());
          }
        }
      }

      // Copy local files
      final docsDir = await getApplicationDocumentsDirectory();
      final filesSource = Directory(p.join(extractDir.path, 'files'));
      if (await filesSource.exists()) {
        await for (final entity in filesSource.list()) {
          if (entity is Directory) {
            final dirName = p.basename(entity.path);
            final targetDir = Directory(p.join(docsDir.path, dirName));
            await targetDir.create(recursive: true);
            await for (final file in entity.list()) {
              if (file is File) {
                await file.copy(p.join(targetDir.path, p.basename(file.path)));
              }
            }
          }
        }
      }

      await extractDir.delete(recursive: true);

      return PackResult(
        success: true,
        recordCount: totalRecords,
        appName: manifest['app_name'] as String? ?? sourceApp,
      );
    } catch (e) {
      return PackResult(success: false, error: e.toString());
    }
  }

  /// Create a task pack to send to Employés app
  static Future<PackResult> createTaskPack({
    required List<Map<String, dynamic>> tasks,
    String? employeeId,
    String? customPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final packId = const Uuid().v4().substring(0, 8);
      final packDir = Directory(p.join(tempDir.path, 'taskpack_$packId'));
      final dataDir = Directory(p.join(packDir.path, 'data'));

      await dataDir.create(recursive: true);

      // Save tasks as JSON
      final tasksFile = File(p.join(dataDir.path, 'tasks.json'));
      await tasksFile.writeAsString(jsonEncode(tasks));

      // Create manifest
      final manifest = {
        'pack_version': packVersion,
        'app': 'admin_to_employes',
        'app_name': 'Tâches Admin → Employés',
        'created_at': DateTime.now().toIso8601String(),
        'pack_id': packId,
        'type': 'tasks',
        'target_employee_id': employeeId,
        'task_count': tasks.length,
      };
      final manifestFile = File(p.join(packDir.path, 'manifest.json'));
      await manifestFile.writeAsString(jsonEncode(manifest));

      // Create ZIP
      final archive = Archive();
      await _addDirectoryToArchive(archive, packDir.path, packDir.path);

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        return PackResult(success: false, error: 'Erreur compression');
      }

      final appDocsDir = await getApplicationDocumentsDirectory();
      final outputDir = customPath ?? p.join(appDocsDir.path, 'packs');
      await Directory(outputDir).create(recursive: true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = p.join(outputDir, 'task_pack_${packId}_$timestamp.yabissopack');

      await File(outputPath).writeAsBytes(zipData);
      await packDir.delete(recursive: true);

      return PackResult(
        success: true,
        filePath: outputPath,
        recordCount: tasks.length,
        appName: 'Tâches',
      );
    } catch (e) {
      return PackResult(success: false, error: e.toString());
    }
  }

  static Future<void> _addDirectoryToArchive(Archive archive, String basePath, String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: basePath);
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }
    }
  }
}
