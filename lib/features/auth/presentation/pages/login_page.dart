import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sweet_mobile_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:sweet_mobile_app/shared/utils/validators.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(authNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    if (ok) {
      // GoRouter redirige automáticamente por el refreshListenable de AuthState
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthFormLoading;
    final errorMsg =
        authState is AuthFormError ? (authState as AuthFormError).message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // ── Logo ─────────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // ── Campos ───────────────────────────────────────
                AuthTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                  enabled: !isLoading,
                  onFieldSubmitted: () => _passwordFocus.requestFocus(),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: AppValidators.password,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: _submit,
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 8),

                // ── Error ─────────────────────────────────────────
                if (errorMsg != null) ...[
                  const SizedBox(height: 8),
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
                ],

                const SizedBox(height: 32),

                // ── Botón login ───────────────────────────────────
                SweetButton(
                  label: 'Iniciar sesión',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // ── Registro ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(authNotifierProvider.notifier).resetError();
                        context.push(RoutePaths.register);
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
