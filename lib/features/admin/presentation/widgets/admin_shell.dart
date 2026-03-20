import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

/// Shell responsivo del panel de admin.
/// - Desktop / Web (≥ 800px): NavigationRail lateral
/// - Mobile (< 800px): BottomNavigationBar
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _AdminTab(
      path: RoutePaths.admin,
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _AdminTab(
      path: RoutePaths.adminUsers,
      icon: Icons.people_rounded,
      label: 'Usuarios',
    ),
    _AdminTab(
      path: RoutePaths.adminBookings,
      icon: Icons.calendar_today_rounded,
      label: 'Reservas',
    ),
    _AdminTab(
      path: RoutePaths.adminReports,
      icon: Icons.flag_rounded,
      label: 'Reportes',
    ),
    _AdminTab(
      path: RoutePaths.adminProfile,
      icon: Icons.manage_accounts_rounded,
      label: 'Perfil',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path ||
          (i > 0 && location.startsWith(_tabs[i].path))) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // ── Side Rail ──────────────────────────────────
            Container(
              color: AppColors.surface,
              child: NavigationRail(
                backgroundColor: AppColors.surface,
                selectedIndex: idx,
                labelType: NavigationRailLabelType.all,
                indicatorColor: AppColors.primary.withOpacity(0.2),
                selectedIconTheme:
                    const IconThemeData(color: AppColors.primary),
                selectedLabelTextStyle:
                    const TextStyle(color: AppColors.primary, fontSize: 12),
                unselectedIconTheme:
                    const IconThemeData(color: AppColors.onSurfaceVariant),
                unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sweet\nAdmin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                destinations: _tabs
                    .map((t) => NavigationRailDestination(
                          icon: Icon(t.icon),
                          label: Text(t.label),
                        ))
                    .toList(),
                onDestinationSelected: (i) => context.go(_tabs[i].path),
              ),
            ),
            const VerticalDivider(
                width: 1, color: AppColors.outlineVariant),
            // ── Contenido ──────────────────────────────────
            Expanded(child: child),
          ],
        ),
      );
    }

    // ── Mobile: Bottom Nav ──────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => context.go(_tabs[i].path),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _AdminTab {
  const _AdminTab(
      {required this.path, required this.icon, required this.label});
  final String path;
  final IconData icon;
  final String label;
}
