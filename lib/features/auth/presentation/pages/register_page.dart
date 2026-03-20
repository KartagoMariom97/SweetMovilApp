import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sweet_mobile_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:sweet_mobile_app/shared/utils/validators.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedRole = 'CLIENT';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authNotifierProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          role: _selectedRole,
        );
    // GoRouter redirige automáticamente si el registro es exitoso
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthFormLoading;
    final errorMsg =
        authState is AuthFormError ? (authState as AuthFormError).message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).resetError();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Encabezado ────────────────────────────────────
                Text(
                  'Cuéntanos sobre ti',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(),

                const SizedBox(height: 8),

                Text(
                  'Tu información es solo para nosotros',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 32),

                // ── Nombre y apellido ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        label: 'Nombre',
                        controller: _firstNameCtrl,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => AppValidators.required(v, 'Nombre'),
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        label: 'Apellido',
                        controller: _lastNameCtrl,
                        validator: (v) => AppValidators.required(v, 'Apellido'),
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                  enabled: !isLoading,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: AppValidators.password,
                  enabled: !isLoading,
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Teléfono (opcional)',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: AppValidators.phone,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // ── Selector de rol ────────────────────────────────
                Text(
                  '¿Cómo quieres usar Sweet?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.onSurface),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _RoleCard(
                      label: 'Quiero contratar',
                      subtitle: 'Soy cliente',
                      icon: Icons.person_search_rounded,
                      value: 'CLIENT',
                      selected: _selectedRole == 'CLIENT',
                      onTap: () => setState(() => _selectedRole = 'CLIENT'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(width: 12),
                    _RoleCard(
                      label: 'Ofrezco servicios',
                      subtitle: 'Soy jornalista',
                      icon: Icons.spa_rounded,
                      value: 'PROVIDER',
                      selected: _selectedRole == 'PROVIDER',
                      onTap: () => setState(() => _selectedRole = 'PROVIDER'),
                      enabled: !isLoading,
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 28),

                // ── Error ─────────────────────────────────────────
                if (errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMsg,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().shake(),
                  const SizedBox(height: 16),
                ],

                // ── Botón ─────────────────────────────────────────
                SweetButton(
                  label: 'Crear cuenta',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 550.ms),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Al registrarte aceptas los Términos de uso\ny la Política de privacidad de Sweet.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
