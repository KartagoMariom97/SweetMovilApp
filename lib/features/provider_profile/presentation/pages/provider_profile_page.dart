import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 12: Perfil público + botón reservar
class ProviderProfilePage extends StatelessWidget {
  const ProviderProfilePage({super.key, required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil Jornalista')),
      body: Center(child: Text('Provider: $providerId — Fase 12')),
    );
  }
}
