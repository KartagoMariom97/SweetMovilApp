import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_requests_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class ProviderRequestsPage extends ConsumerWidget {
  const ProviderRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(providerRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Solicitudes pendientes'),
      ),
      body: requestsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () =>
              ref.read(providerRequestsProvider.notifier).refresh(),
        ),
        data: (requests) => requests.isEmpty
            ? const EmptyState(
                icon: Icons.inbox_rounded,
                title: 'Sin solicitudes pendientes',
                subtitle: 'Cuando un cliente solicite tu servicio, aparecerá aquí.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(providerRequestsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _RequestCard(booking: requests[i]),
                ),
              ),
      ),
    );
  }
}

// ── Request Card ─────────────────────────────────────────────

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(requestActionProvider);
    final isLoading = actionState is RequestActionLoading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.4), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera ────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clientEmail ?? 'Cliente',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(booking.createdAt),
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDIENTE',
                  style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Servicio ─────────────────────────────────────────
          if (booking.service != null) ...[
            _InfoRow(
                icon: Icons.spa_rounded, text: booking.service!.title),
            _InfoRow(
                icon: Icons.attach_money_rounded,
                text: booking.service!.priceLabel),
          ],

          // ── Notas ────────────────────────────────────────────
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _InfoRow(
              icon: Icons.notes_rounded,
              text: booking.notes!,
              maxLines: 2,
            ),

          const SizedBox(height: 16),

          // ── Acciones ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _reject(context, ref),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Denegar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _approve(context, ref),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Aprobar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    // Primero elegir fecha y hora
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !context.mounted) return;

    final scheduledAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);

    final ok = await ref
        .read(requestActionProvider.notifier)
        .approve(booking.id, scheduledAt);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Reserva confirmada para ${_formatDate(scheduledAt)}'
              : 'Error al confirmar'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Denegar solicitud',
            style: TextStyle(color: AppColors.onSurface)),
        content: const Text(
          '¿Confirmas que quieres denegar esta solicitud?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Denegar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final ok =
        await ref.read(requestActionProvider.notifier).reject(booking.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(ok ? 'Solicitud rechazada' : 'Error al rechazar'),
          backgroundColor: ok ? AppColors.onSurfaceVariant : AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.maxLines = 1});
  final IconData icon;
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
