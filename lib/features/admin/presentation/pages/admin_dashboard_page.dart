import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_dashboard_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () => ref.read(adminDashboardProvider.notifier).refresh(),
        ),
        data: (stats) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(adminDashboardProvider.notifier).refresh(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Alerta de reportes pendientes ─────────────
                if (stats.pendingReports > 0)
                  _AlertBanner(
                    message:
                        '${stats.pendingReports} reporte(s) pendiente(s) de revisión',
                    onTap: () => context.go(RoutePaths.adminReports),
                  ),

                if (stats.pendingReports > 0) const SizedBox(height: 16),

                // ── Sección usuarios ─────────────────────────
                _SectionTitle('Usuarios'),
                const SizedBox(height: 12),
                _StatsRow(isWide: isWide, children: [
                  _StatCard(
                    label: 'Total usuarios',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: 'Clientes',
                    value: stats.totalClients.toString(),
                    icon: Icons.person_rounded,
                    color: AppColors.info,
                  ),
                  _StatCard(
                    label: 'Jornaleras',
                    value: stats.totalProviders.toString(),
                    icon: Icons.spa_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'Baneados',
                    value: stats.bannedUsers.toString(),
                    icon: Icons.block_rounded,
                    color: AppColors.error,
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Sección reservas ─────────────────────────
                _SectionTitle('Reservas'),
                const SizedBox(height: 12),
                _StatsRow(isWide: isWide, children: [
                  _StatCard(
                    label: 'Total reservas',
                    value: stats.totalBookings.toString(),
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: 'Pendientes',
                    value: stats.pendingBookings.toString(),
                    icon: Icons.hourglass_empty_rounded,
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    label: 'Completadas',
                    value: stats.completedBookings.toString(),
                    icon: Icons.done_all_rounded,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    label: 'En disputa',
                    value: stats.disputedBookings.toString(),
                    icon: Icons.gavel_rounded,
                    color: AppColors.error,
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Sección reportes ─────────────────────────
                _SectionTitle('Trust Reports'),
                const SizedBox(height: 12),
                _StatsRow(isWide: isWide, children: [
                  _StatCard(
                    label: 'Total reportes',
                    value: stats.totalReports.toString(),
                    icon: Icons.flag_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: 'Pendientes',
                    value: stats.pendingReports.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.warning,
                    highlight: stats.pendingReports > 0,
                  ),
                ]),

                const SizedBox(height: 32),

                // ── Accesos rápidos ──────────────────────────
                _SectionTitle('Accesos rápidos'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      label: 'Ver usuarios',
                      icon: Icons.people_rounded,
                      onTap: () => context.go(RoutePaths.adminUsers),
                    ),
                    _QuickAction(
                      label: 'Ver reservas',
                      icon: Icons.calendar_today_rounded,
                      onTap: () => context.go(RoutePaths.adminBookings),
                    ),
                    _QuickAction(
                      label: 'Reportes pendientes',
                      icon: Icons.flag_rounded,
                      onTap: () => context.go(RoutePaths.adminReports),
                      badge: stats.pendingReports > 0
                          ? stats.pendingReports.toString()
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.children, required this.isWide});
  final List<Widget> children;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: children
            .map((c) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 12), child: c),
                ))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: children,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: highlight ? color : color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.message, required this.onTap});
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.error),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.onSurface, fontSize: 13)),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
