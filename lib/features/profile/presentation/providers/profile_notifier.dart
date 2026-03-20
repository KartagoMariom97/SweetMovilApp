import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/profile/data/datasources/profile_datasource.dart';

// ── Infraestructura ─────────────────────────────────────────

final profileDsProvider = Provider<ProfileDataSource>(
  (ref) => ProfileDataSource(ref.read(dioClientProvider)),
);

// ── State ────────────────────────────────────────────────────

class ClientProfileState {
  const ClientProfileState({
    this.firstName = '',
    this.lastName = '',
    this.bio = '',
    this.location = '',
    this.phone = '',
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  final String firstName;
  final String lastName;
  final String bio;
  final String location;
  final String phone;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  String get fullName => '$firstName $lastName'.trim();

  ClientProfileState copyWith({
    String? firstName,
    String? lastName,
    String? bio,
    String? location,
    String? phone,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      ClientProfileState(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        bio: bio ?? this.bio,
        location: location ?? this.location,
        phone: phone ?? this.phone,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearMessages ? null : error ?? this.error,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );
}

// ── Provider ─────────────────────────────────────────────────

final clientProfileProvider =
    NotifierProvider<ClientProfileNotifier, ClientProfileState>(
  ClientProfileNotifier.new,
);

class ClientProfileNotifier extends Notifier<ClientProfileState> {
  @override
  ClientProfileState build() {
    Future.microtask(_load);
    return const ClientProfileState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final profile = await ref.read(profileDsProvider).getMyProfile();
      state = state.copyWith(
        firstName: profile['firstName'] as String? ??
            profile['first_name'] as String? ??
            '',
        lastName: profile['lastName'] as String? ??
            profile['last_name'] as String? ??
            '',
        bio: profile['bio'] as String? ?? '',
        location: profile['location'] as String? ?? '',
        phone: profile['phone'] as String? ?? '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String bio,
    required String location,
    required String phone,
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      await ref.read(profileDsProvider).updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'location': location,
        'phone': phone,
      });
      state = state.copyWith(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        location: location,
        phone: phone,
        isSaving: false,
        successMessage: 'Perfil actualizado correctamente',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}
