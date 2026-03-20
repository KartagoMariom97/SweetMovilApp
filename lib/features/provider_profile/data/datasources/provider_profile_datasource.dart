import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/provider_profile/data/models/provider_profile_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

class ProviderProfileDataSource {
  const ProviderProfileDataSource(this._client);
  final DioClient _client;

  Future<ProviderProfileModel> fetchProfile(String providerId) async {
    final results = await Future.wait([
      _client.get<Map<String, dynamic>>(
        '/users/$providerId/profile',
        fromJson: (json) => json as Map<String, dynamic>,
      ),
      _client.get<List<dynamic>>(
        '/services',
        queryParams: {'providerId': providerId},
        fromJson: (json) => json as List<dynamic>,
      ),
    ]);

    final profileJson = results[0] as Map<String, dynamic>;
    final servicesList = (results[1] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ServiceModel.fromJson)
        .toList();

    return ProviderProfileModel.fromJson(profileJson, servicesList);
  }
}
