import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yabisso_signature/core/theme/app_theme.dart';
import 'package:yabisso_signature/models/signature.dart';
import 'package:yabisso_signature/providers/providers.dart';
import 'package:yabisso_signature/services/offline_voucher_service.dart';
import 'package:yabisso_signature/services/currency_service.dart';
import 'package:yabisso_signature/helpers/whatsapp_helper.dart';

class SignatureDetailScreen extends ConsumerStatefulWidget {
  final String signatureId;

  const SignatureDetailScreen({super.key, required this.signatureId});

  @override
  ConsumerState<SignatureDetailScreen> createState() => _SignatureDetailScreenState();
}

class _SignatureDetailScreenState extends ConsumerState<SignatureDetailScreen> {
  SignatureModel? _signature;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    final db = ref.read(databaseProvider);
    final map = await db.getSignatureById(widget.signatureId);
    if (map != null && mounted) {
      setState(() {
        _signature = SignatureModel.fromMap(map);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToPdf() async {
    if (_signature == null) return;

    try {
      final service = OfflineVoucherService.instance;
      final filePath = await service.generatePdf(_signature!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF exporte: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _shareSignature() async {
    if (_signature?.signaturePath == null) return;

    try {
      final service = OfflineVoucherService.instance;
      await service.shareSignature(_signature!.signaturePath!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _shareViaWhatsApp() async {
    if (_signature == null) return;

    try {
      await WhatsAppHelper.shareSignatureViaWhatsApp(
        phone: '+22500000000',
        documentName: _signature!.documentName,
        signerName: _signature!.signerName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(SignatureStatus status) async {
    if (_signature == null) return;

    final updated = _signature!.copyWith(status: status);
    await ref.read(signaturesProvider.notifier).updateSignature(updated);
    setState(() => _signature = updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis a jour: ${status.label}')),
      );
    }
  }

  Future<void> _deleteSignature() async {
    if (_signature == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la signature?'),
        content: const Text('Cette action est irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(signaturesProvider.notifier).deleteSignature(_signature!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signature supprimee')),
        );
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Signature')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_signature == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Signature')),
        body: const Center(child: Text('Signature non trouvee')),
      );
    }

    final sig = _signature!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail de la signature'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'draft':
                  _updateStatus(SignatureStatus.brouillon);
                  break;
                case 'signed':
                  _updateStatus(SignatureStatus.signe);
                  break;
                case 'cancelled':
                  _updateStatus(SignatureStatus.annule);
                  break;
                case 'delete':
                  _deleteSignature();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'draft', child: Text('Marquer brouillon')),
              const PopupMenuItem(value: 'signed', child: Text('Marquer signe')),
              const PopupMenuItem(value: 'cancelled', child: Text('Annuler')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sig.documentName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sig.status.index == 1
                                ? AppTheme.successColor
                                : sig.status.index == 0
                                    ? AppTheme.warningColor
                                    : AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            sig.statusLabel,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Signataire', sig.signerName, Icons.person),
                    _buildInfoRow('Email', sig.signerEmail, Icons.email),
                    _buildInfoRow('Type', sig.typeLabel, Icons.category),
                    _buildInfoRow('Date', CurrencyService.formatDateTime(sig.createdAt), Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signature',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (sig.signaturePath != null && File(sig.signaturePath!).existsSync())
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(sig.signaturePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else if (sig.signatureType == SignatureType.texte)
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            sig.signerName,
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: sig.fontStyle,
                              color: sig.textColor != null
                                  ? Color(int.parse('0xFF${sig.textColor}'))
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('Apercu non disponible'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Exporter PDF',
                    Icons.picture_as_pdf,
                    AppTheme.errorColor,
                    _exportToPdf,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Partager',
                    Icons.share,
                    AppTheme.primaryColor,
                    _shareSignature,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'WhatsApp',
                    Icons.chat,
                    AppTheme.successColor,
                    _shareViaWhatsApp,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Supprimer',
                    Icons.delete,
                    AppTheme.errorColor,
                    _deleteSignature,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
