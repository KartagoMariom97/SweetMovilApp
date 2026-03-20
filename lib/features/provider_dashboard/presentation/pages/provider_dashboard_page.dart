import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 13
class ProviderDashboardPage extends StatelessWidget {
  const ProviderDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Provider Dashboard — Fase 13')),
    );
  }
}
