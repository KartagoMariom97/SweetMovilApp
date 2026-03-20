import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/widgets/create_booking_sheet.dart';
import 'package:sweet_mobile_app/features/provider_profile/presentation/providers/provider_profile_notifier.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_avatar.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_card.dart';

class ProviderProfilePage extends ConsumerWidget {
  const ProviderProfilePage({super.key, required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(providerProfileProvider(providerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: EmptyState(
            icon: Icons.error_outline,
            title: 'No pudimos cargar el perfil',
            subtitle: e.toString(),
            action: () => ref.invalidate(providerProfileProvider(providerId)),
            actionLabel: 'Reintentar',
          ),
        ),
        data: (profile) => CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryVariant, AppColors.surface],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        SweetAvatar(
                          imageUrl: profile.avatarUrl,
                          name: profile.fullName,
                          radius: 44,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              profile.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        if (profile.location != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                profile.location!,
                                style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bio ─────────────────────────────────────────
            if (profile.bio != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SweetCard(
                    child: Text(
                      profile.bio!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),

            // ── Servicios ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Servicios disponibles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            if (profile.services.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.spa_outlined,
                  title: 'Sin servicios publicados',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.builder(
                  itemCount: profile.services.length,
                  itemBuilder: (context, i) => _ServiceTile(
                    service: profile.services[i],
                    onBook: () => _showBookingSheet(
                      context,
                      service: profile.services[i],
                      providerId: providerId,
                    ),
                  ).animate().fadeIn(delay: (200 + i * 60).ms),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(
    BuildContext context, {
    required ServiceModel service,
    required String providerId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateBookingSheet(
        service: service,
        providerId: providerId,
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onBook});
  final ServiceModel service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return SweetCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                service.category?.icon ?? '✨',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  service.priceLabel +
                      (service.durationMinutes != null
                          ? ' · ${service.durationMinutes} min'
                          : ''),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          SweetButton(
            label: 'Solicitar',
            onPressed: onBook,
            width: 90,
            height: 36,
          ),
        ],
      ),
    );
  }
}
