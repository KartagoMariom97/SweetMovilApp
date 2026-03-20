import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/provider_profile/data/datasources/provider_profile_datasource.dart';
import 'package:sweet_mobile_app/features/provider_profile/data/models/provider_profile_model.dart';

final providerProfileDsProvider = Provider<ProviderProfileDataSource>(
  (ref) => ProviderProfileDataSource(ref.read(dioClientProvider)),
);

final providerProfileProvider = AsyncNotifierProviderFamily<
    ProviderProfileNotifier,
    ProviderProfileModel,
    String>(ProviderProfileNotifier.new);

class ProviderProfileNotifier
    extends FamilyAsyncNotifier<ProviderProfileModel, String> {
  @override
  Future<ProviderProfileModel> build(String providerId) async {
    final ds = ref.read(providerProfileDsProvider);
    return ds.fetchProfile(providerId);
  }
}
