import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 13
class ProviderRequestsPage extends StatelessWidget {
  const ProviderRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Solicitudes')),
      body: const Center(child: Text('Provider Requests — Fase 13')),
    );
  }
}
