import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_reports_notifier.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/shared/widgets/booking_status_chip.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class AdminBookingsPage extends ConsumerWidget {
  const AdminBookingsPage({super.key});

  static const _filters = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'DISPUTED',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(adminBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(adminBookingsProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: stateAsync.whenData((s) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_filterLabel(f)),
                              selected: s.statusFilter == f,
                              onSelected: (_) => ref
                                  .read(adminBookingsProvider.notifier)
                                  .setFilter(f),
                              selectedColor:
                                  AppColors.primary.withOpacity(0.2),
                              checkmarkColor: AppColors.primary,
                            ),
                          ))
                      .toList(),
                ),
              )).value ??
              const SizedBox(),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () =>
              ref.read(adminBookingsProvider.notifier).refresh(),
        ),
        data: (state) => state.filtered.isEmpty
            ? const EmptyState(
                icon: Icons.calendar_today_rounded,
                title: 'Sin reservas',
                subtitle: 'No hay reservas con ese filtro.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(adminBookingsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _BookingAdminCard(booking: state.filtered[i]),
                ),
              ),
      ),
    );
  }

  String _filterLabel(String f) => switch (f) {
        'ALL' => 'Todas',
        'PENDING' => 'Pendientes',
        'CONFIRMED' => 'Confirmadas',
        'IN_PROGRESS' => 'En curso',
        'COMPLETED' => 'Completadas',
        'CANCELLED' => 'Canceladas',
        'DISPUTED' => 'En disputa',
        _ => f,
      };
}

// ── Booking Card ─────────────────────────────────────────────

class _BookingAdminCard extends StatelessWidget {
  const _BookingAdminCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.service?.title ?? 'Servicio',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BookingStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          _Row(icon: Icons.person_rounded,
              label: 'Cliente: ${booking.clientEmail ?? booking.clientId}'),
          _Row(icon: Icons.spa_rounded,
              label: 'Jornalera: ${booking.providerEmail ?? booking.providerId}'),
          _Row(
            icon: Icons.attach_money_rounded,
            label: '\$${booking.totalPrice.toStringAsFixed(2)}',
          ),
          if (booking.scheduledAt != null)
            _Row(
              icon: Icons.schedule_rounded,
              label: _formatDate(booking.scheduledAt!),
            ),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _Row(icon: Icons.notes_rounded, label: booking.notes!),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
