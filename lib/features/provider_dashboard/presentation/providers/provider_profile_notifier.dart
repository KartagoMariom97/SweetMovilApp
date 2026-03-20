import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/data/datasources/provider_datasource.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_dashboard_notifier.dart';

// ── State ────────────────────────────────────────────────────

class ProviderProfileState {
  const ProviderProfileState({
    this.firstName = '',
    this.lastName = '',
    this.bio = '',
    this.location = '',
    this.isAvailable = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  final String firstName;
  final String lastName;
  final String bio;
  final String location;
  final bool isAvailable;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  ProviderProfileState copyWith({
    String? firstName,
    String? lastName,
    String? bio,
    String? location,
    bool? isAvailable,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      ProviderProfileState(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        bio: bio ?? this.bio,
        location: location ?? this.location,
        isAvailable: isAvailable ?? this.isAvailable,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearMessages ? null : error ?? this.error,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );

  String get fullName => '$firstName $lastName'.trim();
}

// ── Provider ─────────────────────────────────────────────────

final providerProfileProvider =
    NotifierProvider<ProviderProfileNotifier, ProviderProfileState>(
  ProviderProfileNotifier.new,
);

class ProviderProfileNotifier extends Notifier<ProviderProfileState> {
  @override
  ProviderProfileState build() {
    Future.microtask(_load);
    return const ProviderProfileState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ref.read(providerDsProvider).getMyProfile(),
        ref.read(providerDsProvider).getMyProviderProfile(),
      ]);

      final profile = results[0];
      final providerProfile = results[1];

      state = state.copyWith(
        firstName: profile['firstName'] as String? ??
            profile['first_name'] as String? ??
            '',
        lastName: profile['lastName'] as String? ??
            profile['last_name'] as String? ??
            '',
        bio: profile['bio'] as String? ?? '',
        location: profile['location'] as String? ?? '',
        isAvailable: providerProfile['isAvailable'] as bool? ??
            providerProfile['is_available'] as bool? ??
            false,
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
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      await ref.read(providerDsProvider).updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'location': location,
      });
      state = state.copyWith(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        location: location,
        isSaving: false,
        successMessage: 'Perfil actualizado correctamente',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> toggleAvailability() async {
    final newValue = !state.isAvailable;
    state = state.copyWith(isAvailable: newValue);
    try {
      await ref
          .read(providerDsProvider)
          .updateAvailability(isAvailable: newValue);
      ref.invalidate(providerDashboardProvider);
    } catch (e) {
      // Revertir en caso de error
      state = state.copyWith(isAvailable: !newValue, error: e.toString());
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}
