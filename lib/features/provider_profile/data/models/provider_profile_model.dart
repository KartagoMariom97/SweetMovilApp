import 'package:sweet_mobile_app/shared/models/service_model.dart';

class ProviderProfileModel {
  const ProviderProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.services,
    this.avatarUrl,
    this.bio,
    this.location,
    this.isVerified = false,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final bool isVerified;
  final List<ServiceModel> services;

  String get fullName => '$firstName $lastName';

  factory ProviderProfileModel.fromJson(
    Map<String, dynamic> profileJson,
    List<ServiceModel> services,
  ) {
    final user = profileJson['user'] as Map<String, dynamic>? ?? {};
    return ProviderProfileModel(
      userId: (profileJson['userId'] ?? profileJson['user_id'] ?? user['id']) as String,
      firstName: profileJson['firstName'] as String? ??
          profileJson['first_name'] as String,
      lastName: profileJson['lastName'] as String? ??
          profileJson['last_name'] as String,
      avatarUrl: profileJson['avatarUrl'] as String? ?? profileJson['avatar_url'] as String?,
      bio: profileJson['bio'] as String?,
      location: profileJson['location'] as String?,
      isVerified: user['isVerified'] as bool? ?? false,
      services: services,
    );
  }
}
