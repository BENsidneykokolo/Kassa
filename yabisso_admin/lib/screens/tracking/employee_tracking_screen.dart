import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class EmployeeTrackingScreen extends ConsumerStatefulWidget {
  const EmployeeTrackingScreen({super.key});
  @override
  ConsumerState<EmployeeTrackingScreen> createState() => _EmployeeTrackingScreenState();
}

class _EmployeeTrackingScreenState extends ConsumerState<EmployeeTrackingScreen> {
  String _filter = 'pending';
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(checkinRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi des Employés'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _processing ? null : _scanCheckInQr,
            tooltip: 'Scanner pointage',
          ),
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _processing ? null : _pasteCheckInData,
            tooltip: 'Coller depuis WhatsApp',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                final filtered = _filter == 'all'
                    ? requests
                    : requests.where((r) => r['status'] == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'pending' ? 'Aucun pointage en attente' : 'Aucun résultat',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scannez le QR code de l\'employé ou collez les données depuis WhatsApp',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(checkinRequestsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildRequestCard(filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final counts = ref.watch(checkinRequestsProvider).maybeWhen(
      data: (list) => {
        'pending': list.where((r) => r['status'] == 'pending').length,
        'approved': list.where((r) => r['status'] == 'approved').length,
        'rejected': list.where((r) => r['status'] == 'rejected').length,
      },
      orElse: () => <String, int>{},
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _filterChip('pending', 'En attente', counts['pending'] ?? 0, AppColors.primaryAmber),
          const SizedBox(width: 8),
          _filterChip('approved', 'Approuvé', counts['approved'] ?? 0, AppColors.successGreen),
          const SizedBox(width: 8),
          _filterChip('rejected', 'Rejeté', counts['rejected'] ?? 0, AppColors.primaryRed),
          const SizedBox(width: 8),
          _filterChip('all', 'Tous', 0, Colors.grey),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, int count, Color color) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isActive ? color : Colors.grey[600],
            )),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] as String? ?? 'pending';
    final statusColor = status == 'approved'
        ? AppColors.successGreen
        : (status == 'rejected' ? AppColors.primaryRed : AppColors.primaryAmber);
    final statusLabel = status == 'approved' ? 'Approuvé' : (status == 'rejected' ? 'Rejeté' : 'En attente');
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: Icon(
                  isPending ? Icons.access_time : (status == 'approved' ? Icons.check_circle : Icons.cancel),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['employee_name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      (request['employee_id']?.toString() ?? '').length > 12
                          ? request['employee_id'].toString().substring(0, 12)
                          : (request['employee_id']?.toString() ?? ''),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (request['date'] != null && (request['date'] as String).isNotEmpty)
                _infoChip(Icons.calendar_today, request['date'], Colors.grey[600]!),
              if (request['check_in_time'] != null && (request['check_in_time'] as String).isNotEmpty)
                _infoChip(Icons.login, request['check_in_time'], AppColors.successGreen),
              if (request['check_out_time'] != null && (request['check_out_time'] as String).isNotEmpty)
                _infoChip(Icons.logout, request['check_out_time'], Colors.deepPurple),
              if (request['employee_phone'] != null && (request['employee_phone'] as String).isNotEmpty)
                _infoChip(Icons.phone, request['employee_phone'], Colors.grey[600]!),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _processing ? null : () => _approveRequest(request),
                    icon: _processing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _processing ? null : () => _rejectRequest(request),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rejeter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _scanCheckInQr() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 320,
            height: 400,
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    final raw = barcode.rawValue ?? '';
                    if (raw.isEmpty) return;
                    Navigator.pop(ctx);
                    _parseCheckInData(raw);
                  },
                ),
                Positioned(
                  top: 12, left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Scannez le QR code de pointage', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _parseCheckInData(String rawData) {
    try {
      if (rawData.startsWith('YABISSO_EMP:')) {
        final content = rawData.substring('YABISSO_EMP:'.length);

        final lastColonIdx = content.lastIndexOf(':');
        if (lastColonIdx <= 0) {
          _showError('Format QR invalide');
          return;
        }
        final checkOutTime = content.substring(lastColonIdx + 1);
        final beforeCheckout = content.substring(0, lastColonIdx);

        final secondLastColon = beforeCheckout.lastIndexOf(':');
        if (secondLastColon <= 0) {
          _showError('Format QR invalide');
          return;
        }
        final checkInTime = beforeCheckout.substring(secondLastColon + 1);
        final beforeCheckIn = beforeCheckout.substring(0, secondLastColon);

        final thirdLastColon = beforeCheckIn.lastIndexOf(':');
        if (thirdLastColon <= 0) {
          _showError('Format QR invalide');
          return;
        }
        final date = beforeCheckIn.substring(thirdLastColon + 1);
        final beforeDate = beforeCheckIn.substring(0, thirdLastColon);

        final fourthLastColon = beforeDate.lastIndexOf(':');
        if (fourthLastColon <= 0) {
          _showError('Format QR invalide');
          return;
        }
        final phone = beforeDate.substring(fourthLastColon + 1);
        final beforePhone = beforeDate.substring(0, fourthLastColon);

        final firstColon = beforePhone.indexOf(':');
        String employeeId;
        String employeeName;
        if (firstColon > 0) {
          employeeId = beforePhone.substring(0, firstColon);
          employeeName = beforePhone.substring(firstColon + 1);
        } else {
          employeeId = beforePhone;
          employeeName = 'Employé ${beforePhone.length > 8 ? beforePhone.substring(0, 8) : beforePhone}';
        }

        if (employeeId.isEmpty) {
          _showError('ID employé manquant dans le QR code');
          return;
        }

        _addCheckInRequest(
          employeeId: employeeId,
          employeeName: employeeName,
          employeePhone: phone,
          date: date,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime.isNotEmpty ? checkOutTime : null,
        );
      } else {
        _showPasteDialog(rawData);
      }
    } catch (e) {
      _showError('Erreur de parsing du QR: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.primaryRed),
      );
    }
  }

  Future<void> _pasteCheckInData() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _parseSharedText(data.text!);
      } else {
        _showPasteDialog('');
      }
    } catch (_) {
      _showPasteDialog('');
    }
  }

  void _showPasteDialog(String prefill) {
    final controller = TextEditingController(text: prefill);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Coller les données de pointage'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Collez le texte partagé via WhatsApp ici...',
            filled: true, fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _parseSharedText(controller.text);
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  void _parseSharedText(String text) {
    final nameMatch = RegExp(r'Nom:\s*(.+)').firstMatch(text);
    final idMatch = RegExp(r'ID:\s*(.+)').firstMatch(text);
    final phoneMatch = RegExp(r'T[eé]l[eé]phone:\s*(.+)').firstMatch(text);
    final dateMatch = RegExp(r'Date:\s*(.+)').firstMatch(text);
    final timeMatch = RegExp(r"Heure d'arriv[eé]e:\s*(.+)").firstMatch(text);
    final checkoutMatch = RegExp(r"Heure de d[eé]part:\s*(.+)").firstMatch(text);

    if (idMatch != null) {
      _addCheckInRequest(
        employeeId: idMatch.group(1)!.trim(),
        employeeName: nameMatch?.group(1)?.trim() ?? 'Inconnu',
        employeePhone: phoneMatch?.group(1)?.trim() ?? '',
        date: dateMatch?.group(1)?.trim() ?? DateTime.now().toIso8601String().substring(0, 10),
        checkInTime: timeMatch?.group(1)?.trim() ?? '',
        checkOutTime: checkoutMatch?.group(1)?.trim() ?? '',
      );
    } else {
      _showError('Format non reconnu. Collez un message de pointage Yabisso.');
    }
  }

  Future<void> _addCheckInRequest({
    required String employeeId,
    required String employeeName,
    required String employeePhone,
    required String date,
    required String checkInTime,
    String? checkOutTime,
  }) async {
    setState(() => _processing = true);
    try {
      final db = DatabaseHelper.instance;
      final existing = await db.getAll('checkin_requests',
        where: 'employee_id = ? AND date = ? AND status = ?',
        whereArgs: [employeeId, date, 'pending'],
      );
      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pointage déjà en attente pour cet employé aujourd\'hui'), backgroundColor: AppColors.primaryAmber),
          );
        }
        setState(() => _processing = false);
        return;
      }

      await db.insert('checkin_requests', {
        'id': const Uuid().v4(),
        'employee_id': employeeId,
        'employee_name': employeeName,
        'employee_phone': employeePhone,
        'date': date,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime?.isNotEmpty == true ? checkOutTime : null,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      ref.invalidate(checkinRequestsProvider);
      ref.invalidate(pendingCheckinsProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pointage de $employeeName enregistré'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      _showError('Erreur lors de l\'enregistrement: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) {
      _showError('Erreur: ID du pointage introuvable');
      return;
    }

    setState(() => _processing = true);
    try {
      final db = DatabaseHelper.instance;
      final admin = ref.read(currentAdminProvider);

      await db.update('checkin_requests', {
        'status': 'approved',
        'reviewed_by': admin?.id ?? 'admin',
        'reviewed_at': DateTime.now().toIso8601String(),
      }, requestId);

      try {
        await db.logActivity(admin?.id, 'checkin_approved', 'Pointage approuvé: ${request['employee_name']} (${request['date']})');
      } catch (_) {}

      ref.invalidate(checkinRequestsProvider);
      ref.invalidate(pendingCheckinsProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pointage de ${request['employee_name']} approuvé'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      _showError('Erreur lors de l\'approbation: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) {
      _showError('Erreur: ID du pointage introuvable');
      return;
    }

    setState(() => _processing = true);
    try {
      final db = DatabaseHelper.instance;
      final admin = ref.read(currentAdminProvider);

      await db.update('checkin_requests', {
        'status': 'rejected',
        'reviewed_by': admin?.id ?? 'admin',
        'reviewed_at': DateTime.now().toIso8601String(),
      }, requestId);

      try {
        await db.logActivity(admin?.id, 'checkin_rejected', 'Pointage rejeté: ${request['employee_name']} (${request['date']})');
      } catch (_) {}

      ref.invalidate(checkinRequestsProvider);
      ref.invalidate(pendingCheckinsProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pointage de ${request['employee_name']} rejeté'), backgroundColor: AppColors.primaryRed),
        );
      }
    } catch (e) {
      _showError('Erreur lors du rejet: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}
