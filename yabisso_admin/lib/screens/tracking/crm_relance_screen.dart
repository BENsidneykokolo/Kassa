import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class CrmRelanceScreen extends ConsumerStatefulWidget {
  const CrmRelanceScreen({super.key});
  @override
  ConsumerState<CrmRelanceScreen> createState() => _CrmRelanceScreenState();
}

class _CrmRelanceScreenState extends ConsumerState<CrmRelanceScreen> {
  String _searchQuery = '';
  String _viewMode = 'priority';
  String _selectedCategory = 'Tous';
  List<Map<String, dynamic>> _shops = [];
  List<Map<String, dynamic>> _contactHistory = [];
  bool _loading = true;

  static const _categories = [
    'Tous', 'Boutique', 'Restaurant', 'Quincaillerie', 'Pharmacie',
    'Salon de coiffure', 'Hôtel', 'Bar', 'Épicerie', 'Supermarché', 'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final shops = await DatabaseHelper.instance.getAll('prospectives', orderBy: 'created_at DESC');
    final history = await DatabaseHelper.instance.getAll('contact_history', orderBy: 'created_at DESC');
    setState(() { _shops = shops; _contactHistory = history; _loading = false; });
  }

  int _daysSinceLastContact(Map<String, dynamic> shop) {
    final lastContact = shop['last_contact_date'] ?? shop['updated_at'] ?? '';
    if (lastContact.isEmpty) return 999;
    try {
      final dt = DateTime.parse(lastContact);
      return DateTime.now().difference(dt).inDays;
    } catch (_) {
      return 999;
    }
  }

  String _priorityLabel(int days) {
    if (days <= 15) return 'normal';
    if (days <= 30) return 'surveiller';
    if (days <= 45) return 'prioritaire';
    return 'urgent';
  }

  Color _priorityColor(int days) {
    if (days <= 15) return AppColors.primaryGreen;
    if (days <= 30) return AppColors.primaryBlue;
    if (days <= 45) return AppColors.primaryAmber;
    return AppColors.primaryRed;
  }

  IconData _priorityIcon(int days) {
    if (days <= 15) return Icons.check_circle;
    if (days <= 30) return Icons.info_outline;
    if (days <= 45) return Icons.warning_amber;
    return Icons.error;
  }

  List<Map<String, dynamic>> get _filteredShops {
    var list = _shops.where((s) {
      if (_selectedCategory != 'Tous' && s['category'] != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final name = (s['shop_name'] ?? '').toString().toLowerCase();
        final owner = (s['owner_name'] ?? '').toString().toLowerCase();
        final phone = (s['owner_phone'] ?? '').toString();
        if (!name.contains(_searchQuery.toLowerCase()) &&
            !owner.contains(_searchQuery.toLowerCase()) &&
            !phone.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();

    if (_viewMode == 'priority') {
      list.sort((a, b) => _daysSinceLastContact(b).compareTo(_daysSinceLastContact(a)));
    }
    return list;
  }

  List<Map<String, dynamic>> get _urgentShops {
    return _filteredShops.where((s) => _daysSinceLastContact(s) > 30).toList();
  }

  int get _contactedCount => _shops.where((s) {
    final history = _contactHistory.where((h) => h['shop_id'] == s['id']).toList();
    return history.isNotEmpty;
  }).length;

  int get _notContactedCount => _shops.length - _contactedCount;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredShops;
    final urgentCount = _urgentShops.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CRM Relance'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (urgentCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(12)),
              child: Text('$urgentCount urgent', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : Column(
              children: [
                _buildStatsBar(urgentCount),
                _buildSearchBar(),
                _buildViewModeTabs(),
                _buildCategoryFilter(),
                Expanded(child: filtered.isEmpty ? _buildEmptyState() : _buildShopList(filtered)),
              ],
            ),
    );
  }

  Widget _buildStatsBar(int urgentCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _miniStat('${_shops.length}', 'Total', AppColors.primaryBlue),
          const SizedBox(width: 6),
          _miniStat('$_contactedCount', 'Contactés', AppColors.primaryGreen),
          const SizedBox(width: 6),
          _miniStat('$_notContactedCount', 'Non contactés', AppColors.primaryAmber),
          const SizedBox(width: 6),
          _miniStat('$urgentCount', 'Urgents', AppColors.primaryRed),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher commerce, propriétaire, téléphone...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => setState(() => _searchQuery = ''))
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildViewModeTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _viewTab('priority', 'Par priorité', Icons.sort),
          const SizedBox(width: 8),
          _viewTab('all', 'Tous', Icons.list),
          const SizedBox(width: 8),
          _viewTab('urgent', 'Urgents', Icons.warning_amber),
        ],
      ),
    );
  }

  Widget _viewTab(String mode, String label, IconData icon) {
    final isActive = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? AppColors.primaryBlue : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? Colors.white : Colors.grey),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isActive = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? AppColors.primaryBlue : AppColors.border),
                ),
                child: Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.grey[600])),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucun commerce trouvé', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 4),
          Text('Commencez par ajouter des commerces via le démarchage', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShopList(List<Map<String, dynamic>> shops) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shops.length,
        itemBuilder: (ctx, i) => _buildShopCard(shops[i]),
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    final days = _daysSinceLastContact(shop);
    final priority = _priorityLabel(days);
    final color = _priorityColor(days);
    final icon = _priorityIcon(days);
    final shopId = shop['id'] ?? '';
    final shopHistory = _contactHistory.where((h) => h['shop_id'] == shopId).toList();
    final lastContact = shopHistory.isNotEmpty ? shopHistory.first : null;
    final isContacted = shopHistory.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: days > 30 ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showShopDetail(shop),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop['shop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          '${shop['category'] ?? 'Autre'} • ${shop['owner_name'] ?? 'Inconnu'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days >= 999 ? 'Jamais contacté' : 'Il y a ${days}j',
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              if (shop['owner_phone'] != null && (shop['owner_phone'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(shop['owner_phone'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const Spacer(),
                      if (isContacted)
                        Row(
                          children: [
                            Icon(Icons.history, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text('${shopHistory.length} contact(s)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                    ],
                  ),
                ),
              if (lastContact != null && lastContact['notes'] != null && (lastContact['notes'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.note, size: 12, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lastContact['notes'],
                            style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _actionButton(Icons.phone, 'Appeler', AppColors.primaryGreen, () => _callShop(shop)),
                  const SizedBox(width: 6),
                  _actionButton(Icons.chat_bubble_outline, 'WhatsApp', AppColors.primaryGreen, () => _openWhatsApp(shop)),
                  const SizedBox(width: 6),
                  _actionButton(Icons.note_add, 'Note', AppColors.primaryBlue, () => _showAddNoteDialog(shop)),
                  const SizedBox(width: 6),
                  _actionButton(Icons.check_circle_outline, 'Contacté', AppColors.primaryGreen, () => _markAsContacted(shop)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showShopDetail(Map<String, dynamic> shop) {
    final days = _daysSinceLastContact(shop);
    final color = _priorityColor(days);
    final shopId = shop['id'] ?? '';
    final shopHistory = _contactHistory.where((h) => h['shop_id'] == shopId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_priorityIcon(days), color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop['shop_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${shop['category'] ?? 'Autre'} • ${shop['owner_name'] ?? 'Inconnu'}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailInfoRow(Icons.phone, 'Téléphone', shop['owner_phone'] ?? 'Non renseigné'),
              _detailInfoRow(Icons.location_on, 'Adresse', shop['address'] ?? 'Non renseignée'),
              _detailInfoRow(Icons.calendar_today, 'Dernière visite', _formatDate(shop['visit_date'] ?? '')),
              _detailInfoRow(Icons.timer, 'Depuis', days >= 999 ? 'Jamais contacté' : '$days jour(s)'),
              _detailInfoRow(Icons.flag, 'Priorité', _priorityLabel(days).toUpperCase(), color: color),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => _callShop(shop),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Appeler'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(shop),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryGreen, side: const BorderSide(color: AppColors.primaryGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _showAddNoteDialog(shop); },
                    icon: const Icon(Icons.note_add, size: 18),
                    label: const Text('Ajouter une note'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue, side: const BorderSide(color: AppColors.primaryBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _markAsContacted(shop); },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Marquer contacté'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Text('Historique des contacts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey[800])),
              const SizedBox(height: 10),
              if (shopHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('Aucun contact enregistré', style: TextStyle(color: Colors.grey[500], fontSize: 13))),
                )
              else
                ...shopHistory.map((h) => _buildHistoryItem(h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[500]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: color ?? Colors.grey[800], fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final channel = entry['channel'] ?? 'appel';
    final result = entry['result'] ?? '';
    final notes = entry['notes'] ?? '';
    final agent = entry['agent_name'] ?? '';
    final createdAt = entry['created_at'] ?? '';

    IconData channelIcon;
    Color channelColor;
    switch (channel) {
      case 'whatsapp':
        channelIcon = Icons.chat_bubble_outline;
        channelColor = AppColors.primaryGreen;
        break;
      case 'appel':
        channelIcon = Icons.phone;
        channelColor = AppColors.primaryBlue;
        break;
      default:
        channelIcon = Icons.info_outline;
        channelColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(channelIcon, size: 14, color: channelColor),
              const SizedBox(width: 6),
              Text(channel.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: channelColor)),
              const Spacer(),
              Text(_formatDateTime(createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primaryAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(result, style: const TextStyle(fontSize: 10, color: AppColors.primaryAmber, fontWeight: FontWeight.w600)),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(notes, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
          if (agent.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Par: $agent', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Non renseignée';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _callShop(Map<String, dynamic> shop) async {
    final phone = shop['owner_phone'] ?? '';
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun numéro de téléphone'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final uri = Uri.parse('tel:${Uri.encodeComponent(phone)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le téléphone'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openWhatsApp(Map<String, dynamic> shop) async {
    final phone = shop['owner_phone'] ?? '';
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun numéro de téléphone'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      final uri = Uri.parse('https://wa.me/$cleaned');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final webUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleaned');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp non installé'), backgroundColor: Colors.orange),
          );
        }
      }
    }
  }

  void _showAddNoteDialog(Map<String, dynamic> shop) {
    final notesController = TextEditingController();
    String channel = 'appel';
    String result = 'relance_necessaire';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Note pour ${shop['shop_name'] ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Canal de contact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _channelChip('appel', 'Appel', Icons.phone, channel == 'appel', () => setModalState(() => channel = 'appel')),
                    const SizedBox(width: 8),
                    _channelChip('whatsapp', 'WhatsApp', Icons.chat_bubble_outline, channel == 'whatsapp', () => setModalState(() => channel = 'whatsapp')),
                    const SizedBox(width: 8),
                    _channelChip('visite', 'Visite', Icons.store, channel == 'visite', () => setModalState(() => channel = 'visite')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Résultat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _resultChip('satisfait', 'Client satisfait', result == 'satisfait', () => setModalState(() => result = 'satisfait')),
                    _resultChip('probleme', 'Problème signalé', result == 'probleme', () => setModalState(() => result = 'probleme')),
                    _resultChip('aide', 'Demande d\'aide', result == 'aide', () => setModalState(() => result = 'aide')),
                    _resultChip('relance_necessaire', 'Relance nécessaire', result == 'relance_necessaire', () => setModalState(() => result = 'relance_necessaire')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Décrivez l\'interaction (obligatoire)...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (notesController.text.isEmpty) return;
                      await _saveContactNote(shop, channel, result, notesController.text);
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Enregistrer la note'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _channelChip(String value, String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.primaryBlue : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _resultChip(String value, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryAmber.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.primaryAmber : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? AppColors.primaryAmber : Colors.grey[600])),
      ),
    );
  }

  Future<void> _saveContactNote(Map<String, dynamic> shop, String channel, String result, String notes) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();
    final entry = {
      'id': const Uuid().v4(),
      'shop_id': shop['id'] ?? '',
      'shop_name': shop['shop_name'] ?? '',
      'agent_name': 'Admin',
      'channel': channel,
      'result': result,
      'notes': notes,
      'created_at': now,
    };
    await db.insert('contact_history', entry);
    await db.update('prospectives', {
      'last_contact_date': now,
      'updated_at': now,
    }, shop['id']);
    await db.logActivity(null, 'crm_contact', 'Contact ${shop['shop_name']}: $channel - $result');
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note enregistrée'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _markAsContacted(Map<String, dynamic> shop) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();
    final entry = {
      'id': const Uuid().v4(),
      'shop_id': shop['id'] ?? '',
      'shop_name': shop['shop_name'] ?? '',
      'agent_name': 'Admin',
      'channel': 'appel',
      'result': 'contacte',
      'notes': 'Marqué comme contacté',
      'created_at': now,
    };
    await db.insert('contact_history', entry);
    await db.update('prospectives', {
      'last_contact_date': now,
      'manager_status': 'contacted',
      'updated_at': now,
    }, shop['id']);
    await db.logActivity(null, 'crm_contact', 'Commerce contacté: ${shop['shop_name']}');
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${shop['shop_name']} marqué comme contacté'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}
