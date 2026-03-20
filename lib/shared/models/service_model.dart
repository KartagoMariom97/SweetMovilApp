import 'package:sweet_mobile_app/shared/models/category_model.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.price,
    required this.priceType,
    this.description,
    this.durationMinutes,
    this.isActive = true,
    this.category,
    this.providerEmail,
  });

  final String id;
  final String providerId;
  final String title;
  final double price;
  final String priceType; // HOUR | SESSION | FIXED
  final String? description;
  final int? durationMinutes;
  final bool isActive;
  final CategoryModel? category;
  final String? providerEmail;

  String get priceLabel {
    final p = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return switch (priceType) {
      'HOUR' => '\$$p/hr',
      'SESSION' => '\$$p/sesión',
      _ => '\$$p',
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final catJson = json['category'] as Map<String, dynamic>?;
    final provJson = json['provider'] as Map<String, dynamic>?;
    return ServiceModel(
      id: json['id'] as String,
      providerId: (json['providerId'] ?? json['provider_id'] ?? provJson?['id']) as String,
      title: json['title'] as String,
      price: double.parse(json['price'].toString()),
      priceType: json['priceType'] as String? ?? json['price_type'] as String,
      description: json['description'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      category: catJson != null ? CategoryModel.fromJson(catJson) : null,
      providerEmail: provJson?['email'] as String?,
    );
  }
}
