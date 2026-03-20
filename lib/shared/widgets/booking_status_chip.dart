import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (String, Color) _resolve(String status) => switch (status) {
        'PENDING' => ('Pendiente', AppColors.bookingPending),
        'CONFIRMED' => ('Confirmada', AppColors.bookingConfirmed),
        'IN_PROGRESS' => ('En curso', AppColors.bookingInProgress),
        'COMPLETED' => ('Completada', AppColors.bookingCompleted),
        'CANCELLED' => ('Cancelada', AppColors.bookingCancelled),
        'DISPUTED' => ('Disputada', AppColors.bookingDisputed),
        _ => (status, AppColors.onSurfaceVariant),
      };
}
