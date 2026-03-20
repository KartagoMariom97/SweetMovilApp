import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/providers/bookings_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/booking_status_chip.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_card.dart';

class BookingDetailPage extends ConsumerWidget {
  const BookingDetailPage({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Reserva'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: bookingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'No pudimos cargar la reserva',
          subtitle: e.toString(),
        ),
        data: (booking) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Estado ───────────────────────────────────
              Row(
                children: [
                  Text('Estado:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 12),
                  BookingStatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 20),

              // ── Servicio ──────────────────────────────────
              SweetCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(
                      label: 'Servicio',
                      value: booking.service?.title ?? '—',
                    ),
                    const Divider(height: 20),
                    _Row(
                      label: 'Precio total',
                      value: '\$${booking.totalPrice.toStringAsFixed(2)}',
                      valueColor: AppColors.primary,
                    ),
                    if (booking.scheduledAt != null) ...[
                      const Divider(height: 20),
                      _Row(
                        label: 'Fecha',
                        value:
                            '${booking.scheduledAt!.day}/${booking.scheduledAt!.month}/${booking.scheduledAt!.year} '
                            '${booking.scheduledAt!.hour.toString().padLeft(2, '0')}:'
                            '${booking.scheduledAt!.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                    if (booking.notes != null) ...[
                      const Divider(height: 20),
                      _Row(label: 'Notas', value: booking.notes!),
                    ],
                    const Divider(height: 20),
                    _Row(
                      label: 'Creada',
                      value:
                          '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Ir al chat ────────────────────────────────
              SweetButton(
                label: 'Abrir chat',
                variant: SweetButtonVariant.outlined,
                icon: Icons.chat_rounded,
                onPressed: () {
                  // Crear/obtener conversación y navegar al chat
                  // La lógica de crear conversación es en ChatPage
                  context.push('/chat/new?providerId=${booking.providerId}&bookingId=${booking.id}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
