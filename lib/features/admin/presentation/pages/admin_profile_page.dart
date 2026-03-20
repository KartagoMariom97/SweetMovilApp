import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sweet_mobile_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

// ── State ────────────────────────────────────────────────────

class _ProfileState {
  const _ProfileState({
    this.firstName = '',
    this.lastName = '',
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  final String firstName;
  final String lastName;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  _ProfileState copyWith({
    String? firstName,
    String? lastName,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      _ProfileState(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearMessages ? null : error ?? this.error,
        successMessage: clearMessages ? null : successMessage ?? this.successMessage,
      );
}

// ── Provider ─────────────────────────────────────────────────

final _adminProfileProvider =
    NotifierProvider<_AdminProfileNotifier, _ProfileState>(
  _AdminProfileNotifier.new,
);

class _AdminProfileNotifier extends Notifier<_ProfileState> {
  @override
  _ProfileState build() {
    Future.microtask(_load);
    return const _ProfileState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final profile = await ref.read(adminDsProvider).getMyProfile();
      state = state.copyWith(
        firstName: profile['firstName'] as String? ??
            profile['first_name'] as String? ??
            '',
        lastName: profile['lastName'] as String? ??
            profile['last_name'] as String? ??
            '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> save(String firstName, String lastName) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      await ref.read(adminDsProvider).updateProfile({
        'firstName': firstName,
        'lastName': lastName,
      });
      state = state.copyWith(
        firstName: firstName,
        lastName: lastName,
        isSaving: false,
        successMessage: 'Perfil actualizado',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

// ── Page ─────────────────────────────────────────────────────

class AdminProfilePage extends ConsumerStatefulWidget {
  const AdminProfilePage({super.key});

  @override
  ConsumerState<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends ConsumerState<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(_adminProfileProvider);

    if (!_initialized && !ps.isLoading) {
      _firstNameCtrl.text = ps.firstName;
      _lastNameCtrl.text = ps.lastName;
      _initialized = true;
    }

    ref.listen(_adminProfileProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: AppColors.success,
        ));
        ref.read(_adminProfileProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ));
        ref.read(_adminProfileProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Perfil Admin'),
      ),
      body: ps.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.error.withOpacity(0.2),
                      child: Text(
                        ps.firstName.isNotEmpty
                            ? ps.firstName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMINISTRADOR',
                        style: TextStyle(
                            color: AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Nombre
                    Row(
                      children: [
                        Expanded(
                          child: _Field(
                            controller: _firstNameCtrl,
                            label: 'Nombre',
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(
                            controller: _lastNameCtrl,
                            label: 'Apellido',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    SweetButton.primary(
                      label: ps.isSaving ? 'Guardando...' : 'Guardar cambios',
                      onPressed: ps.isSaving ? null : _save,
                    ),
                    const SizedBox(height: 16),
                    SweetButton.outlined(
                      label: 'Cerrar sesión',
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(_adminProfileProvider.notifier)
        .save(_firstNameCtrl.text.trim(), _lastNameCtrl.text.trim());
  }

  Future<void> _logout(BuildContext context) async {
    await ref.read(authNotifierProvider.notifier).logout();
    ref.read(authStateProvider).setLoggedOut();
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
    );
  }
}
