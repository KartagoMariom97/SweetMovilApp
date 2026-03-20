import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_dashboard_notifier.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_profile_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/booking_status_chip.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class ProviderDashboardPage extends ConsumerWidget {
  const ProviderDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(providerDashboardProvider);
    final profileState = ref.watch(providerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(providerDashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.surface,
              expandedHeight: 100,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileState.isLoading
                          ? 'Hola!'
                          : 'Hola, ${profileState.firstName.isEmpty ? 'Jornalera' : profileState.firstName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: profileState.isAvailable
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profileState.isAvailable
                              ? 'Disponible'
                              : 'No disponible',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Contenido ─────────────────────────────────────
            statsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error al cargar',
                  subtitle: e.toString(),
                  actionLabel: 'Reintentar',
                  onAction: () =>
                      ref.read(providerDashboardProvider.notifier).refresh(),
                ),
              ),
              data: (stats) => SliverList(
                delegate: SliverChildListDelegate([
                  // Resumen estadístico
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StatsGrid(stats: stats),
                        const SizedBox(height: 24),

                        // Acceso rápido — solicitudes pendientes
                        if (stats.pending > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Solicitudes pendientes (${stats.pending})',
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context
                                    .goNamed(RouteNames.providerRequests),
                                child: const Text('Ver todas'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...stats.recentPending.map(
                            (b) => _PendingBookingCard(booking: b),
                          ),
                        ] else
                          const _NoPendingBanner(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Grid ───────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final ProviderStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Pendientes',
          value: stats.pending.toString(),
          color: AppColors.warning,
          icon: Icons.hourglass_empty_rounded,
        ),
        _StatCard(
          label: 'Confirmadas',
          value: stats.confirmed.toString(),
          color: AppColors.bookingConfirmed,
          icon: Icons.check_circle_outline_rounded,
        ),
        _StatCard(
          label: 'Completadas',
          value: stats.completed.toString(),
          color: AppColors.success,
          icon: Icons.done_all_rounded,
        ),
        _StatCard(
          label: 'Ingresos',
          value: '\$${stats.estimatedEarnings.toStringAsFixed(0)}',
          color: AppColors.primary,
          icon: Icons.attach_money_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pending Booking Card ─────────────────────────────────────

class _PendingBookingCard extends ConsumerWidget {
  const _PendingBookingCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_rounded, color: AppColors.primary),
        title: Text(
          booking.service?.title ?? 'Servicio',
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
        ),
        subtitle: Text(
          booking.clientEmail ?? 'Cliente',
          style: const TextStyle(
              color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookingStatusChip(status: 'PENDING'),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant),
          ],
        ),
        onTap: () => context.goNamed(RouteNames.providerRequests),
      ),
    );
  }
}

// ── No Pending Banner ────────────────────────────────────────

class _NoPendingBanner extends StatelessWidget {
  const _NoPendingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sin solicitudes pendientes. ¡Todo al día!',
              style:
                  TextStyle(color: AppColors.onSurface, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
