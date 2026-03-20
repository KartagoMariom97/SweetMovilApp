import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      final role = await storage.getUserRole();
      ref.read(authStateProvider).setLoggedIn(role: role ?? 'CLIENT');
      if (!mounted) return;
      final destination = switch (role) {
        'ADMIN' => RoutePaths.admin,
        'PROVIDER' => RoutePaths.providerDashboard,
        _ => RoutePaths.home,
      };
      context.go(destination);
    } else {
      final local = ref.read(localStorageProvider);
      context.go(
        local.onboardingSeen ? RoutePaths.login : RoutePaths.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 52),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),
            const SizedBox(height: 24),
            Text(
              'Sweet',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.onSurface,
                    letterSpacing: -1,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Servicios de confianza',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
