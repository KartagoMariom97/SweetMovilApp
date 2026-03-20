import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 11: implementar con AuthNotifier + Riverpod
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: const Center(child: Text('Registro — Fase 11')),
    );
  }
}
