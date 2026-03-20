import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/home/presentation/providers/home_notifier.dart';
import 'package:sweet_mobile_app/features/home/presentation/widgets/service_card.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_avatar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(homeServicesProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¡Hola! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¿Qué servicio necesitas hoy?',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      SweetAvatar(
                        name: authState.role ?? 'U',
                        radius: 22,
                        showBadge: true,
                        isOnline: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Barra de búsqueda rápida ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GestureDetector(
                onTap: () => context.go(RoutePaths.search),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.onSurfaceVariant, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Masajes, manicure, peluquería...',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
          ),

          // ── Título sección ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Servicios disponibles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          // ── Lista de servicios ──────────────────────────
          servicesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'No pudimos cargar los servicios',
                subtitle: e.toString(),
                action: () => ref.invalidate(homeServicesProvider),
                actionLabel: 'Reintentar',
              ),
            ),
            data: (services) {
              if (services.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.spa_outlined,
                    title: 'Sin servicios disponibles',
                    subtitle: 'Vuelve pronto, nuevas jornalistas se están sumando.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.builder(
                  itemCount: services.length,
                  itemBuilder: (context, i) => ServiceCard(
                    service: services[i],
                    onTap: () => context.push(
                      '/provider/${services[i].providerId}',
                    ),
                  ).animate().fadeIn(delay: (i * 50).ms).slideY(begin: 0.1, end: 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
