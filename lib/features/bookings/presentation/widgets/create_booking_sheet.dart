import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/providers/bookings_notifier.dart';
import 'package:sweet_mobile_app/shared/extensions/context_extensions.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class CreateBookingSheet extends ConsumerStatefulWidget {
  const CreateBookingSheet({
    super.key,
    required this.service,
    required this.providerId,
  });

  final ServiceModel service;
  final String providerId;

  @override
  ConsumerState<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends ConsumerState<CreateBookingSheet> {
  final _notesCtrl = TextEditingController();
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    final ok = await ref.read(createBookingProvider.notifier).create(
          service: widget.service,
          providerId: widget.providerId,
          scheduledAt: _scheduledAt,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      context.pop();
      context.showSnack('¡Solicitud enviada! La jornalista confirmará pronto.');
      context.go(RoutePaths.bookings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createBookingProvider);
    final isLoading = state is CreateBookingLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ───────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Servicio ─────────────────────────────────────
          Text('Solicitar servicio',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(widget.service.category?.icon ?? '✨',
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.service.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.service.priceLabel,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Fecha preferida ──────────────────────────────
          OutlinedButton.icon(
            onPressed: isLoading ? null : _pickDate,
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              _scheduledAt == null
                  ? 'Elegir fecha y hora (opcional)'
                  : '${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year} '
                      '${_scheduledAt!.hour.toString().padLeft(2, '0')}:'
                      '${_scheduledAt!.minute.toString().padLeft(2, '0')}',
            ),
          ),

          const SizedBox(height: 12),

          // ── Notas ─────────────────────────────────────────
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Notas para la jornalista (opcional)',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 24),

          if (state is CreateBookingError) ...[
            Text(
              (state as CreateBookingError).message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],

          SweetButton(
            label: 'Enviar solicitud',
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
