import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sweet_mobile_app/features/profile/presentation/providers/profile_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initControllers(ClientProfileState ps) {
    if (_initialized || ps.isLoading) return;
    _firstNameCtrl.text = ps.firstName;
    _lastNameCtrl.text = ps.lastName;
    _bioCtrl.text = ps.bio;
    _locationCtrl.text = ps.location;
    _phoneCtrl.text = ps.phone;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(clientProfileProvider);
    _initControllers(ps);

    ref.listen(clientProfileProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: AppColors.success,
        ));
        ref.read(clientProfileProvider.notifier).clearMessages();
      }
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ));
        ref.read(clientProfileProvider.notifier).clearMessages();
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
                    // ── Avatar ─────────────────────────────────
                    Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            AppColors.secondary.withOpacity(0.2),
                        child: Text(
                          ps.firstName.isNotEmpty
                              ? ps.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (ps.fullName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          ps.fullName,
                          style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // ── Nombre ──────────────────────────────────
                    const _SectionLabel('Información personal'),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    _Field(
                      controller: _phoneCtrl,
                      label: 'Teléfono',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_rounded,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      controller: _locationCtrl,
                      label: 'Ubicación',
                      prefixIcon: Icons.location_on_rounded,
                      hint: 'Ej: Buenos Aires, CABA',
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      controller: _bioCtrl,
                      label: 'Bio',
                      maxLines: 3,
                      hint: 'Cuéntanos sobre ti...',
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
    await ref.read(clientProfileProvider.notifier).saveProfile(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
  }

  Future<void> _logout(BuildContext context) async {
    await ref.read(authNotifierProvider.notifier).logout();
    ref.read(authStateProvider).setLoggedOut();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
