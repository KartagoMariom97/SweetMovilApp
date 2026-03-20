import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

class HomeDataSource {
  const HomeDataSource(this._client);
  final DioClient _client;

  Future<List<ServiceModel>> fetchServices({String? categoryId}) async {
    final list = await _client.get<List<dynamic>>(
      '/services',
      queryParams: {
        if (categoryId != null) 'categoryId': categoryId,
      },
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(ServiceModel.fromJson)
        .toList();
  }
}
