import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/home/data/datasources/home_datasource.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

final _homeDsProvider = Provider<HomeDataSource>(
  (ref) => HomeDataSource(ref.read(dioClientProvider)),
);

final homeServicesProvider =
    AsyncNotifierProvider<HomeNotifier, List<ServiceModel>>(HomeNotifier.new);

class HomeNotifier extends AsyncNotifier<List<ServiceModel>> {
  @override
  Future<List<ServiceModel>> build() => _fetch();

  Future<List<ServiceModel>> _fetch({String? categoryId}) async {
    final ds = ref.read(_homeDsProvider);
    return ds.fetchServices(categoryId: categoryId);
  }

  Future<void> refresh({String? categoryId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(categoryId: categoryId));
  }
}
