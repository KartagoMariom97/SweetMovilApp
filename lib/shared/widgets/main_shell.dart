import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.role});

  final Widget child;
  final String role; // 'CLIENT' | 'PROVIDER'

  @override
  Widget build(BuildContext context) {
    final tabs = role == 'PROVIDER' ? _providerTabs : _clientTabs;
    final currentIndex = _currentIndex(context, tabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(tabs[i].path),
        items: tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }

  int _currentIndex(BuildContext context, List<_TabItem> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path)) return i;
    }
    return 0;
  }

  static const _clientTabs = [
    _TabItem(path: RoutePaths.home, icon: Icons.home_rounded, label: 'Inicio'),
    _TabItem(path: RoutePaths.search, icon: Icons.search_rounded, label: 'Buscar'),
    _TabItem(path: RoutePaths.bookings, icon: Icons.calendar_today_rounded, label: 'Reservas'),
    _TabItem(path: RoutePaths.notifications, icon: Icons.notifications_rounded, label: 'Alertas'),
    _TabItem(path: RoutePaths.profile, icon: Icons.person_rounded, label: 'Perfil'),
  ];

  static const _providerTabs = [
    _TabItem(path: RoutePaths.providerDashboard, icon: Icons.dashboard_rounded, label: 'Inicio'),
    _TabItem(path: RoutePaths.providerRequests, icon: Icons.inbox_rounded, label: 'Solicitudes'),
    _TabItem(path: RoutePaths.providerServices, icon: Icons.spa_rounded, label: 'Servicios'),
    _TabItem(path: RoutePaths.providerChatList, icon: Icons.chat_rounded, label: 'Chat'),
    _TabItem(path: RoutePaths.providerProfileEdit, icon: Icons.person_rounded, label: 'Perfil'),
  ];
}

class _TabItem {
  const _TabItem({required this.path, required this.icon, required this.label});
  final String path;
  final IconData icon;
  final String label;
}
