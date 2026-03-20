import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/home/presentation/widgets/service_card.dart';
import 'package:sweet_mobile_app/features/search/presentation/providers/search_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buscar servicios'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chips de categorías ─────────────────────────
          categoriesAsync.when(
            loading: () => const SizedBox(height: 56),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    final isAll = state.selectedCategoryId == null;
                    return FilterChip(
                      label: const Text('Todos'),
                      selected: isAll,
                      onSelected: (_) => notifier.clearCategory(),
                    );
                  }
                  final cat = categories[i - 1];
                  final selected = state.selectedCategoryId == cat.id;
                  return FilterChip(
                    avatar: Text(cat.icon),
                    label: Text(cat.name),
                    selected: selected,
                    onSelected: (_) => notifier.search(categoryId: cat.id),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Resultados ──────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.error != null
                    ? EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Error al cargar',
                        subtitle: state.error,
                        action: notifier.clearCategory,
                        actionLabel: 'Reintentar',
                      )
                    : state.results.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Sin resultados',
                            subtitle:
                                'No encontramos servicios en esta categoría.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                            itemCount: state.results.length,
                            itemBuilder: (context, i) => ServiceCard(
                              service: state.results[i],
                              onTap: () => context.push(
                                '/provider/${state.results[i].providerId}',
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (i * 40).ms)
                                .slideY(begin: 0.05, end: 0),
                          ),
          ),
        ],
      ),
    );
  }
}
