import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/data/datasources/provider_datasource.dart';
import 'package:sweet_mobile_app/shared/models/category_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

// ── State ───────────────────────────────────────────────────

sealed class ServiceFormState {}

final class ServiceFormIdle extends ServiceFormState {}

final class ServiceFormLoading extends ServiceFormState {}

final class ServiceFormSuccess extends ServiceFormState {}

final class ServiceFormError extends ServiceFormState {
  ServiceFormError(this.message);
  final String message;
}

// ── Providers ───────────────────────────────────────────────

final providerServicesProvider =
    AsyncNotifierProvider<ProviderServicesNotifier, List<ServiceModel>>(
  ProviderServicesNotifier.new,
);

final categoriesForFormProvider =
    FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(providerDsProvider).getCategories();
});

final serviceFormProvider =
    NotifierProvider<ServiceFormNotifier, ServiceFormState>(
  ServiceFormNotifier.new,
);

// ── Services Notifier ────────────────────────────────────────

class ProviderServicesNotifier extends AsyncNotifier<List<ServiceModel>> {
  @override
  Future<List<ServiceModel>> build() => _load();

  Future<List<ServiceModel>> _load() async {
    final userId = await ref.read(secureStorageProvider).getUserId();
    if (userId == null) return [];
    return ref.read(providerDsProvider).getMyServices(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> delete(String serviceId) async {
    await ref.read(providerDsProvider).deleteService(serviceId);
    await refresh();
  }
}

// ── Form Notifier (create / edit) ────────────────────────────

class ServiceFormNotifier extends Notifier<ServiceFormState> {
  @override
  ServiceFormState build() => ServiceFormIdle();

  Future<bool> submit({
    String? existingId,
    required String title,
    required String description,
    required double price,
    required String priceType,
    required String categoryId,
    int? durationMinutes,
  }) async {
    state = ServiceFormLoading();
    try {
      final data = {
        'title': title,
        'description': description,
        'price': price,
        'priceType': priceType,
        'categoryId': categoryId,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      };

      if (existingId != null) {
        await ref.read(providerDsProvider).updateService(existingId, data);
      } else {
        await ref.read(providerDsProvider).createService(data);
      }

      state = ServiceFormSuccess();
      ref.invalidate(providerServicesProvider);
      return true;
    } catch (e) {
      state = ServiceFormError(e.toString());
      return false;
    }
  }

  void reset() => state = ServiceFormIdle();
}
