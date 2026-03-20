import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 13
class ProviderServicesPage extends StatelessWidget {
  const ProviderServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis Servicios')),
      body: const Center(child: Text('Provider Services — Fase 13')),
    );
  }
}
