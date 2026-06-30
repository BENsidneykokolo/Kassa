import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_theme.dart';
import '../../models/employee.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class EmployeeActivityScreen extends ConsumerStatefulWidget {
  const EmployeeActivityScreen({super.key});
  @override
  ConsumerState<EmployeeActivityScreen> createState() => _EmployeeActivityScreenState();
}

class _EmployeeActivityScreenState extends ConsumerState<EmployeeActivityScreen> {
  static const _primary = AppColors.primaryGreen;
  String _searchQuery = '';
  bool _loading = false;
  String? _uploadedFileName;
  Map<String, dynamic>? _parsedData;
  String? _matchedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Activité Employé', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(),
            const SizedBox(height: 20),
            if (_parsedData != null) ...[
              _buildParsedDataSection(),
              const SizedBox(height: 20),
            ],
            const Text('Liste des employés', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 12),
            employeesAsync.when(
              data: (employees) {
                final filtered = _searchQuery.isEmpty
                    ? employees
                    : employees.where((e) =>
                        e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        e.phone.contains(_searchQuery)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('Aucun employé trouvé'));
                }
                return Column(
                  children: filtered.map((e) => _buildEmployeeCard(e)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.upload_file, color: _primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Importer un rapport de ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Importez le fichier de rapport partagé par un employé via WhatsApp. L\'app identifiera automatiquement l\'employé et mettra à jour son profil.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _pickFile,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.file_upload, size: 20),
              label: Text(_loading ? 'Importation...' : 'Choisir un fichier', style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_uploadedFileName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
                const SizedBox(width: 6),
                Text(_uploadedFileName!, style: const TextStyle(fontSize: 12, color: AppColors.successGreen)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParsedDataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: _primary, size: 22),
              const SizedBox(width: 10),
              const Text('Données extraites', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDataItem('Employé', _parsedData!['employee_name'] ?? 'Inconnu'),
          _buildDataItem('Ventes', '${_parsedData!['sales_count'] ?? 0} abonnement(s)'),
          _buildDataItem('Total ventes', '${_parsedData!['total_amount'] ?? 0} FCFA'),
          _buildDataItem('Salaire du jour', '${_parsedData!['daily_salary'] ?? 0} FCFA'),
          if ((_parsedData!['total_commission'] ?? 0) > 0)
            _buildDataItem('Commissions', '${_parsedData!['total_commission'] ?? 0} FCFA'),
          _buildDataItem('Boutiques', '${_parsedData!['boutiques_count'] ?? 0}'),
          if (_matchedEmployeeId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyToProfile,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Appliquer au profil', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Rechercher un employé...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final initials = employee.initials.isNotEmpty
        ? employee.initials
        : (employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E');
    final isMatched = _matchedEmployeeId == employee.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMatched ? _primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isMatched ? _primary : Colors.transparent, width: isMatched ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(int.parse(employee.color.replaceFirst('#', '0xFF'))),
            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(employee.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('ID: ${employee.id}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: employee.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              employee.isActive ? 'Actif' : 'Inactif',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: employee.isActive ? const Color(0xFF388E3C) : const Color(0xFFC62828)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
      );
      if (result == null || result.files.isEmpty) return;

      setState(() => _loading = true);

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      setState(() => _uploadedFileName = result.files.first.name);

      _parseReport(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _parseReport(String content) {
    final lines = content.split('\n');
    String employeeName = '';
    int totalAmount = 0;
    int totalCommission = 0;
    int salesCount = 0;
    int boutiquesCount = 0;
    final Set<String> boutiques = {};

    for (final line in lines) {
      if (line.startsWith('Employé:')) {
        employeeName = line.replaceFirst('Employé:', '').trim();
      } else if (line.startsWith('Total ventes:')) {
        final match = RegExp(r'([\d\s]+)').firstMatch(line.replaceFirst('Total ventes:', '').trim());
        if (match != null) {
          totalAmount = int.tryParse(match.group(1)!.replaceAll(' ', '')) ?? 0;
        }
      } else if (line.startsWith('Commissions:')) {
        final match = RegExp(r'([\d\s]+)').firstMatch(line.replaceFirst('Commissions:', '').trim());
        if (match != null) {
          totalCommission = int.tryParse(match.group(1)!.replaceAll(' ', '')) ?? 0;
        }
      } else if (line.startsWith('Ventes:')) {
        final match = RegExp(r'(\d+)').firstMatch(line);
        if (match != null) salesCount = int.tryParse(match.group(1)!) ?? 0;
      } else if (line.startsWith('Boutiques visitées:')) {
        final match = RegExp(r'(\d+)').firstMatch(line);
        if (match != null) boutiquesCount = int.tryParse(match.group(1)!) ?? 0;
      } else if (line.trim().startsWith('- ')) {
        boutiques.add(line.trim().replaceFirst('- ', ''));
      }
    }

    final dailySalary = (totalAmount * 0.2).toInt();

    final employees = ref.read(employeesProvider).valueOrNull ?? [];
    Employee? matched;
    for (final e in employees) {
      if (e.name.toLowerCase() == employeeName.toLowerCase()) {
        matched = e;
        break;
      }
    }

    setState(() {
      _parsedData = {
        'employee_name': employeeName,
        'total_amount': totalAmount,
        'total_commission': totalCommission,
        'sales_count': salesCount,
        'boutiques_count': boutiquesCount > 0 ? boutiquesCount : boutiques.length,
        'daily_salary': dailySalary,
        'boutiques': boutiques.toList(),
      };
      _matchedEmployeeId = matched?.id;
    });

    if (matched == null && employeeName.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun employé trouvé pour "$employeeName". Vérifiez le nom.'),
            backgroundColor: AppColors.primaryAmber,
          ),
        );
      }
    }
  }

  Future<void> _applyToProfile() async {
    if (_parsedData == null || _matchedEmployeeId == null) return;

    setState(() => _loading = true);
    try {
      final db = DatabaseHelper.instance;
      final employeeId = _matchedEmployeeId!;
      final now = DateTime.now().toIso8601String();

      await db.insert('sale_records', {
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'employee_id': employeeId,
        'employee_name': _parsedData!['employee_name'] ?? '',
        'shop_name': (_parsedData!['boutiques'] as List<String>?)?.join(', ') ?? '',
        'plan': 'DAILY_REPORT',
        'amount': _parsedData!['total_amount'] ?? 0,
        'commission': _parsedData!['total_commission'] ?? 0,
        'created_at': now,
      });

      ref.invalidate(allSalesProvider);
      ref.invalidate(employeesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil employé mis à jour avec succès !'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        setState(() {
          _parsedData = null;
          _matchedEmployeeId = null;
          _uploadedFileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
