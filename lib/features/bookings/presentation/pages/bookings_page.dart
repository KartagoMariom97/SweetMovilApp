import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/providers/bookings_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/booking_status_chip.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_card.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(bookingsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Error al cargar reservas',
          subtitle: e.toString(),
          action: () => ref.read(bookingsProvider.notifier).refresh(),
          actionLabel: 'Reintentar',
        ),
        data: (bookings) => bookings.isEmpty
            ? const EmptyState(
                icon: Icons.calendar_today_outlined,
                title: 'Sin reservas aún',
                subtitle:
                    'Explora los servicios y haz tu primera solicitud.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(bookingsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) => _BookingCard(
                    booking: bookings[i],
                    onTap: () =>
                        context.push('/booking/${bookings[i].id}'),
                  ).animate().fadeIn(delay: (i * 50).ms),
                ),
              ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});
  final BookingModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SweetCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.service?.title ?? 'Servicio',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              BookingStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.providerEmail ?? booking.clientEmail ?? '—',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (booking.scheduledAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${booking.scheduledAt!.day}/${booking.scheduledAt!.month}/${booking.scheduledAt!.year}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
