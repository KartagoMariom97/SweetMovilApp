import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 11: implementar con AuthNotifier + Riverpod
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(RoutePaths.register),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
