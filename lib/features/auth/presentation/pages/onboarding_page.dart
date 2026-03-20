import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

// Implementación completa en Fase 11
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.spa_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 32),
              Text(
                'Descubre servicios\nde confianza',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Conectamos clientes con jornalistas\nverificados. Tu seguridad primero.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              SweetButton(
                label: 'Comenzar',
                onPressed: () async {
                  await ref.read(localStorageProvider).setOnboardingSeen();
                  if (context.mounted) context.go(RoutePaths.login);
                },
              ),
              const SizedBox(height: 12),
              SweetButton(
                label: 'Ya tengo cuenta',
                variant: SweetButtonVariant.ghost,
                onPressed: () => context.go(RoutePaths.login),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
