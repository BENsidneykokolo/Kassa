import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/permissions_service.dart';
import '../../services/pdf_export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});
  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _exporting = false;
  String? _lastExportPath;

  bool _hasPermission(String permission) {
    final admin = ref.read(currentAdminProvider);
    if (admin == null) return false;
    return PermissionsService.instance.hasPermission(admin.role, permission);
  }

  Future<void> _exportPdf(String type) async {
    if (!_hasPermission('reports_export')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous n\'avez pas la permission d\'exporter')),
        );
      }
      return;
    }

    setState(() => _exporting = true);

    try {
      File file;
      switch (type) {
        case 'employees':
          file = await PdfExportService.instance.exportEmployeesPdf();
          break;
        case 'attendance':
          file = await PdfExportService.instance.exportAttendancePdf();
          break;
        case 'leaves':
          file = await PdfExportService.instance.exportLeavesPdf();
          break;
        case 'candidates':
          file = await PdfExportService.instance.exportCandidatesPdf();
          break;
        case 'performance':
          file = await PdfExportService.instance.exportPerformancePdf();
          break;
        case 'daily_report':
          file = await PdfExportService.instance.exportDailyReportPdf();
          break;
        default:
          throw Exception('Type d\'export inconnu');
      }

      setState(() {
        _lastExportPath = file.path;
        _exporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi: ${file.path.split('/').last}'),
            action: SnackBarAction(
              label: 'Partager',
              onPressed: () => _shareFile(file),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _exporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'export: $e')),
        );
      }
    }
  }

  Future<void> _shareFile(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Rapport Yabisso Admin');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de partage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Export de rapports'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _exporting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen),
                  SizedBox(height: 16),
                  Text('Export en cours...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Rapports disponibles'),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Liste des employés',
                    'Export complet de tous les employés avec leurs informations',
                    Icons.people,
                    AppColors.primaryGreen,
                    () => _exportPdf('employees'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Présence du jour',
                    'Rapport de présence des employés pour aujourd\'hui',
                    Icons.access_time,
                    AppColors.primaryBlue,
                    () => _exportPdf('attendance'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Gestion des congés',
                    'Liste de toutes les demandes de congés',
                    Icons.event_busy,
                    AppColors.primaryAmber,
                    () => _exportPdf('leaves'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Candidats',
                    'Liste de tous les candidats avec leur statut',
                    Icons.person_search,
                    AppColors.primaryBlue,
                    () => _exportPdf('candidates'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Performance des employés',
                    'Analyse de performance basée sur les tâches et la présence',
                    Icons.trending_up,
                    AppColors.primaryGreen,
                    () => _exportPdf('performance'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 12),
                  _buildExportCard(
                    'Rapport quotidien',
                    'Résumé complet de l\'activité du jour',
                    Icons.assessment,
                    AppColors.primaryRed,
                    () => _exportPdf('daily_report'),
                    _hasPermission('reports_export'),
                  ),
                  const SizedBox(height: 20),
                  if (_lastExportPath != null) ...[
                    _buildSectionTitle('Dernier export'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description, color: AppColors.primaryGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lastExportPath!.split('/').last,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _lastExportPath!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: AppColors.primaryGreen),
                            onPressed: () => _shareFile(File(_lastExportPath!)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool hasAccess,
  ) {
    return GestureDetector(
      onTap: hasAccess ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAccess ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: hasAccess ? color.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasAccess ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: hasAccess ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasAccess ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasAccess ? description : 'Accès refusé',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (hasAccess)
              Icon(Icons.download, color: color)
            else
              const Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}