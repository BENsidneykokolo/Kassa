import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Coquille de navigation principale (mobile) : bottom navigation +
/// menu "Plus" pour accéder à tous les modules secondaires, comme demandé
/// dans le prompt UI/UX ("navigation adaptée avec bottom navigation, menu
/// Plus, accès rapide aux fonctions principales").
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    _TabDef('/dashboard', Icons.dashboard_rounded, 'Accueil'),
    _TabDef('/rooms', Icons.meeting_room_rounded, 'Chambres'),
    _TabDef('/reservations', Icons.event_available_rounded, 'Réservations'),
    _TabDef('/more', Icons.grid_view_rounded, 'Plus'),
  ];

  int _indexFor(String location) {
    final i = _tabs.indexWhere((t) => location.startsWith(t.path));
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        items: _tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _TabDef {
  final String path;
  final IconData icon;
  final String label;
  const _TabDef(this.path, this.icon, this.label);
}

/// Grille "Plus" : accès à tous les modules secondaires.
class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  static const _entries = [
    _MoreEntry('/reception', Icons.support_agent_rounded, 'Réception'),
    _MoreEntry('/checkin', Icons.login_rounded, 'Check-in'),
    _MoreEntry('/checkout', Icons.logout_rounded, 'Check-out'),
    _MoreEntry('/pos-restaurant', Icons.restaurant_rounded, 'Caisse Restaurant'),
    _MoreEntry('/pos-bar', Icons.local_bar_rounded, 'Caisse Bar'),
    _MoreEntry('/room-service', Icons.room_service_rounded, 'Room Service'),
    _MoreEntry('/employees', Icons.badge_rounded, 'Employés'),
    _MoreEntry('/attendance', Icons.qr_code_scanner_rounded, 'Pointage'),
    _MoreEntry('/housekeeping', Icons.cleaning_services_rounded, 'Housekeeping'),
    _MoreEntry('/maintenance', Icons.build_rounded, 'Maintenance'),
    _MoreEntry('/inventory', Icons.inventory_2_rounded, 'Stocks'),
    _MoreEntry('/finance', Icons.account_balance_wallet_rounded, 'Finances'),
    _MoreEntry('/crm', Icons.people_alt_rounded, 'Clients / CRM'),
    _MoreEntry('/marketing', Icons.campaign_rounded, 'Marketing'),
    _MoreEntry('/analytics', Icons.query_stats_rounded, 'Analytics'),
    _MoreEntry('/ai-manager', Icons.auto_awesome_rounded, 'AI Hotel Manager'),
    _MoreEntry('/client-portal', Icons.wifi_rounded, 'Portail Client'),
    _MoreEntry('/notifications', Icons.notifications_rounded, 'Notifications'),
    _MoreEntry('/settings', Icons.settings_rounded, 'Paramètres'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tous les modules')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: _entries.length,
        itemBuilder: (context, i) {
          final e = _entries[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(e.path),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(e.icon, color: AppColors.primary, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    e.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreEntry {
  final String path;
  final IconData icon;
  final String label;
  const _MoreEntry(this.path, this.icon, this.label);
}
