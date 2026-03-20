class UserAdminModel {
  const UserAdminModel({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.phone,
    this.isAvailable,
  });

  final String id;
  final String email;
  final String role; // CLIENT | PROVIDER | ADMIN
  final bool isActive;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool? isAvailable; // solo PROVIDER

  String get displayName {
    final name = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return name.isEmpty ? email : name.join(' ');
  }

  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final providerProfile =
        json['providerProfile'] as Map<String, dynamic>? ??
            json['provider_profile'] as Map<String, dynamic>?;

    return UserAdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String),
      firstName: profile?['firstName'] as String? ??
          profile?['first_name'] as String?,
      lastName:
          profile?['lastName'] as String? ?? profile?['last_name'] as String?,
      phone: profile?['phone'] as String?,
      isAvailable: providerProfile?['isAvailable'] as bool? ??
          providerProfile?['is_available'] as bool?,
    );
  }
}
