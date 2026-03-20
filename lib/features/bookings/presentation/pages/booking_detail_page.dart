import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 12
class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle de Reserva')),
      body: Center(child: Text('Booking: $bookingId — Fase 12')),
    );
  }
}
