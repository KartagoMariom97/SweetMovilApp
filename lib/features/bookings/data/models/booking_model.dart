import 'package:sweet_mobile_app/shared/models/service_model.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.scheduledAt,
    this.notes,
    this.service,
    this.providerEmail,
    this.clientEmail,
  });

  final String id;
  final String clientId;
  final String providerId;
  final String serviceId;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String? notes;
  final ServiceModel? service;
  final String? providerEmail;
  final String? clientEmail;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'] as Map<String, dynamic>?;
    final providerJson = json['provider'] as Map<String, dynamic>?;
    final clientJson = json['client'] as Map<String, dynamic>?;
    return BookingModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String? ?? json['client_id'] as String,
      providerId: json['providerId'] as String? ?? json['provider_id'] as String,
      serviceId: json['serviceId'] as String? ?? json['service_id'] as String,
      status: json['status'] as String,
      totalPrice: double.parse(json['totalPrice']?.toString() ??
          json['total_price'].toString()),
      createdAt: DateTime.parse(json['createdAt'] as String? ??
          json['created_at'] as String),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      notes: json['notes'] as String?,
      service: serviceJson != null ? ServiceModel.fromJson(serviceJson) : null,
      providerEmail: providerJson?['email'] as String?,
      clientEmail: clientJson?['email'] as String?,
    );
  }
}
