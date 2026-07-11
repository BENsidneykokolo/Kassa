import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class PdfExportService {
  static final PdfExportService instance = PdfExportService._init();
  PdfExportService._init();

  final _db = DatabaseHelper.instance;
  final _formatter = DateFormat('dd/MM/yyyy HH:mm');

  Future<String> _getExportPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  Future<File> exportEmployeesPdf() async {
    final pdf = pw.Document();
    final employees = await _db.getAll('employees', orderBy: 'name ASC');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Liste des Employés', employees.length),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['Nom', 'Poste', 'Département', 'Téléphone', 'Statut'],
            data: employees.map((e) => [
              e['name']?.toString() ?? '',
              e['position']?.toString() ?? '',
              e['department']?.toString() ?? '',
              e['phone']?.toString() ?? '',
              e['status']?.toString() ?? 'actif',
            ]).toList(),
          ),
        ],
      ),
    );

    return _savePdf(pdf, 'employes_${_formatDateForFile()}.pdf');
  }

  Future<File> exportAttendancePdf({String? date}) async {
    final pdf = pw.Document();
    final targetDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
    final attendance = await _db.getAll('attendance', where: 'date = ?', whereArgs: [targetDate]);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Présence du $targetDate', attendance.length),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headers: ['Employé', 'Heure arrivée', 'Heure départ', 'Statut'],
            data: attendance.map((a) => [
              a['employee_name']?.toString() ?? '',
              a['check_in']?.toString() ?? '',
              a['check_out']?.toString() ?? '',
              a['status']?.toString() ?? '',
            ]).toList(),
          ),
        ],
      ),
    );

    return _savePdf(pdf, 'presence_$targetDate.pdf');
  }

  Future<File> exportLeavesPdf() async {
    final pdf = pw.Document();
    final leaves = await _db.getAll('leaves', orderBy: 'created_at DESC');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Gestion des Congés', leaves.length),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headers: ['Employé', 'Type', 'Début', 'Fin', 'Statut'],
            data: leaves.map((l) => [
              l['employee_name']?.toString() ?? '',
              l['type']?.toString() ?? '',
              l['start_date']?.toString() ?? '',
              l['end_date']?.toString() ?? '',
              l['status']?.toString() ?? '',
            ]).toList(),
          ),
        ],
      ),
    );

    return _savePdf(pdf, 'conges_${_formatDateForFile()}.pdf');
  }

  Future<File> exportCandidatesPdf() async {
    final pdf = pw.Document();
    final candidates = await _db.getAll('candidates', orderBy: 'created_at DESC');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Liste des Candidats', candidates.length),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headers: ['Nom', 'Poste', 'Téléphone', 'Statut', 'Date'],
            data: candidates.map((c) => [
              c['name']?.toString() ?? '',
              c['position']?.toString() ?? '',
              c['phone']?.toString() ?? '',
              c['status']?.toString() ?? '',
              c['created_at']?.toString().substring(0, 10) ?? '',
            ]).toList(),
          ),
        ],
      ),
    );

    return _savePdf(pdf, 'candidats_${_formatDateForFile()}.pdf');
  }

  Future<File> exportPerformancePdf() async {
    final pdf = pw.Document();
    final employees = await _db.getAll('employees');

    final performanceData = <Map<String, dynamic>>[];
    for (final emp in employees) {
      final tasks = await _db.getAll('employee_tasks', where: 'employee_id = ?', whereArgs: [emp['id']]);
      final completedTasks = tasks.where((t) => t['status'] == 'completed').length;
      final totalTasks = tasks.length;

      final attendance = await _db.getAll('attendance', where: 'employee_id = ?', whereArgs: [emp['id']]);
      final presentDays = attendance.where((a) => a['status'] == 'present' || a['status'] == 'late').length;

      performanceData.add({
        'name': emp['name']?.toString() ?? '',
        'tasks_completed': completedTasks,
        'tasks_total': totalTasks,
        'attendance_rate': attendance.isNotEmpty ? ((presentDays / attendance.length) * 100).toStringAsFixed(0) : '0',
      });
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Performance des Employés', performanceData.length),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headers: ['Employé', 'Tâches terminées', 'Tâches totales', 'Taux présence'],
            data: performanceData.map((p) => [
              p['name']?.toString() ?? '',
              '${p['tasks_completed']}/${p['tasks_total']}',
              p['tasks_total'].toString(),
              '${p['attendance_rate']}%',
            ]).toList(),
          ),
        ],
      ),
    );

    return _savePdf(pdf, 'performance_${_formatDateForFile()}.pdf');
  }

  Future<File> exportDailyReportPdf() async {
    final pdf = pw.Document();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final employees = await _db.getAll('employees');
    final attendance = await _db.getAll('attendance', where: 'date = ?', whereArgs: [today]);
    final tasks = await _db.getAll('employee_tasks');
    final todayTasks = tasks.where((t) {
      final created = t['created_at']?.toString().substring(0, 10);
      return created == today;
    }).toList();

    final presentCount = attendance.where((a) => a['status'] == 'present' || a['status'] == 'late').length;
    final absentCount = employees.length - attendance.length;
    final lateCount = attendance.where((a) => a['status'] == 'late').length;
    final completedToday = todayTasks.where((t) => t['status'] == 'completed').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Rapport Quotidien - $today', 0),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.Header(text: 'Résumé', level: 1),
          pw.SizedBox(height: 10),
          _buildSummaryRow('Total employés', '${employees.length}'),
          _buildSummaryRow('Présents', '$presentCount'),
          _buildSummaryRow('Absents', '$absentCount'),
          _buildSummaryRow('En retard', '$lateCount'),
          _buildSummaryRow('Tâches créées', '${todayTasks.length}'),
          _buildSummaryRow('Tâches terminées', '$completedToday'),
          pw.SizedBox(height: 20),
          pw.Header(text: 'Détail des présences', level: 1),
          pw.SizedBox(height: 10),
          if (attendance.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 30,
              headers: ['Employé', 'Statut', 'Arrivée', 'Départ'],
              data: attendance.map((a) => [
                a['employee_name']?.toString() ?? '',
                a['status']?.toString() ?? '',
                a['check_in']?.toString() ?? '',
                a['check_out']?.toString() ?? '-',
              ]).toList(),
            )
          else
            pw.Text('Aucune donnée de présence pour aujourd\'hui'),
        ],
      ),
    );

    return _savePdf(pdf, 'rapport_$today.pdf');
  }

  pw.Widget _buildHeader(String title, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#00694C'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Généré le ${_formatter.format(DateTime.now())}', style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            ],
          ),
          if (count > 0)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Text('$count éléments', style: const pw.TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Yabisso Admin - Système de Gestion RH', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.Text('Page ${DateTime.now().year}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateForFile() {
    return DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
  }

  Future<File> _savePdf(pw.Document pdf, String filename) async {
    final path = await _getExportPath();
    final file = File('$path/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}