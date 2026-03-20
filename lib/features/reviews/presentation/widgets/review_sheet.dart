import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/reviews/presentation/providers/review_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

/// Bottom sheet para dejar una reseña post-servicio.
/// Solo se muestra cuando booking.status == 'COMPLETED'.
class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final isLoading = reviewState is ReviewLoading;

    ref.listen(reviewProvider, (_, next) {
      if (next is ReviewSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu reseña!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(reviewProvider.notifier).reset();
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ─────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Deja tu reseña',
                style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tu opinión ayuda a otros clientes y motiva a las jornaleras.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // ── Estrellas ──────────────────────────────────────
          const Text(
            'Calificación',
            style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _rating >= starIndex
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 40,
                    color: _rating >= starIndex
                        ? AppColors.warning
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0)
            Center(
              child: Text(
                _ratingLabel(_rating),
                style: const TextStyle(
                    color: AppColors.warning, fontWeight: FontWeight.w500),
              ),
            ),
          const SizedBox(height: 20),

          // ── Comentario ─────────────────────────────────────
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
              hintText:
                  '¿Cómo fue tu experiencia con la jornalera?',
              hintStyle:
                  TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (reviewState is ReviewError)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                reviewState.message,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),

          SweetButton.primary(
            label: isLoading ? 'Enviando...' : 'Enviar reseña',
            onPressed: (_rating == 0 || isLoading) ? null : _submit,
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int r) => switch (r) {
        1 => 'Malo',
        2 => 'Regular',
        3 => 'Bueno',
        4 => 'Muy bueno',
        5 => 'Excelente',
        _ => '',
      };

  Future<void> _submit() async {
    await ref.read(reviewProvider.notifier).submit(
          bookingId: widget.bookingId,
          rating: _rating,
          comment: _commentCtrl.text.trim(),
        );
  }
}
