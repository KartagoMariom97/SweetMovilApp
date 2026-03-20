import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/home/data/datasources/home_datasource.dart';
import 'package:sweet_mobile_app/shared/models/category_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

// ── Categorías ──────────────────────────────────────────────

final _categoriesDsProvider = Provider<HomeDataSource>(
  (ref) => HomeDataSource(ref.read(dioClientProvider)),
);

final categoriesProvider =
    FutureProvider<List<CategoryModel>>((ref) async {
  final client = ref.read(dioClientProvider);
  final list = await client.get<List<dynamic>>(
    '/services/categories',
    fromJson: (json) => json as List<dynamic>,
  );
  return list.cast<Map<String, dynamic>>().map(CategoryModel.fromJson).toList();
});

// ── Estado de búsqueda ─────────────────────────────────────

class SearchState {
  const SearchState({
    this.selectedCategoryId,
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  final String? selectedCategoryId;
  final List<ServiceModel> results;
  final bool isLoading;
  final String? error;

  SearchState copyWith({
    String? selectedCategoryId,
    List<ServiceModel>? results,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) =>
      SearchState(
        selectedCategoryId:
            clearCategory ? null : selectedCategoryId ?? this.selectedCategoryId,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

final searchNotifierProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    // Carga inicial con todos los servicios
    Future.microtask(search);
    return const SearchState(isLoading: true);
  }

  Future<void> search({String? categoryId}) async {
    state = state.copyWith(
      isLoading: true,
      selectedCategoryId: categoryId,
      clearError: true,
    );
    try {
      final ds = ref.read(_categoriesDsProvider);
      final results = await ds.fetchServices(categoryId: categoryId);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        results: [],
      );
    }
  }

  void clearCategory() => search();
}
