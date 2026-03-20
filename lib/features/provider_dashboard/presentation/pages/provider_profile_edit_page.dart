import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_profile_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class ProviderProfileEditPage extends ConsumerStatefulWidget {
  const ProviderProfileEditPage({super.key});

  @override
  ConsumerState<ProviderProfileEditPage> createState() =>
      _ProviderProfileEditPageState();
}

class _ProviderProfileEditPageState
    extends ConsumerState<ProviderProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameCtrl = TextEditingController();
  late final _lastNameCtrl = TextEditingController();
  late final _bioCtrl = TextEditingController();
  late final _locationCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _initControllers(ProviderProfileState ps) {
    if (_initialized || ps.isLoading) return;
    _firstNameCtrl.text = ps.firstName;
    _lastNameCtrl.text = ps.lastName;
    _bioCtrl.text = ps.bio;
    _locationCtrl.text = ps.location;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(providerProfileProvider);
    _initControllers(ps);

    ref.listen(providerProfileProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: AppColors.success,
        ));
        ref.read(providerProfileProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ));
        ref.read(providerProfileProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mi Perfil'),
      ),
      body: ps.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar placeholder ──────────────────────
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.2),
                            child: Text(
                              ps.firstName.isNotEmpty
                                  ? ps.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Disponibilidad ──────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ps.isAvailable
                              ? AppColors.success.withOpacity(0.4)
                              : AppColors.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Disponible para trabajar',
                          style: TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          ps.isAvailable
                              ? 'Tu perfil aparece activo para clientes'
                              : 'Tu perfil está oculto para nuevas solicitudes',
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 12),
                        ),
                        value: ps.isAvailable,
                        activeColor: AppColors.success,
                        onChanged: (_) => ref
                            .read(providerProfileProvider.notifier)
                            .toggleAvailability(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Información personal',
                      style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // ── Nombre ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _firstNameCtrl,
                            label: 'Nombre',
                            validator: (v) => (v?.isEmpty ?? true)
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FormField(
                            controller: _lastNameCtrl,
                            label: 'Apellido',
                            validator: (v) => (v?.isEmpty ?? true)
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Bio ─────────────────────────────────────
                    _FormField(
                      controller: _bioCtrl,
                      label: 'Descripción / Bio',
                      maxLines: 3,
                      hint:
                          'Cuéntale a los clientes sobre ti y tu experiencia...',
                    ),
                    const SizedBox(height: 12),

                    // ── Ubicación ───────────────────────────────
                    _FormField(
                      controller: _locationCtrl,
                      label: 'Ubicación',
                      hint: 'Ej: Buenos Aires, CABA',
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 28),

                    // ── Guardar ─────────────────────────────────
                    SweetButton.primary(
                      label: ps.isSaving ? 'Guardando...' : 'Guardar cambios',
                      onPressed: ps.isSaving ? null : _save,
                    ),
                    const SizedBox(height: 16),

                    // ── Cerrar sesión ───────────────────────────
                    SweetButton.outlined(
                      label: 'Cerrar sesión',
                      onPressed: () => _logout(context, ref),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(providerProfileProvider.notifier).saveProfile(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
        );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
    ref.read(authStateProvider).setLoggedOut();
  }
}

// ── Form Field ────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.hint,
    this.prefixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 18)
            : null,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
    );
  }
}
