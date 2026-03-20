import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 12: Lista de reservas con estados coloreados
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: const Center(child: Text('Bookings — Fase 12')),
    );
  }
}
