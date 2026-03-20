import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/admin/data/models/user_admin_model.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_users_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Usuarios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Buscador
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Buscar por email o nombre...',
                    hintStyle:
                        const TextStyle(color: AppColors.onSurfaceVariant),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.onSurfaceVariant),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (q) =>
                      ref.read(adminUsersProvider.notifier).search(q),
                ),
              ),
              // Filtro por rol
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: ['ALL', 'CLIENT', 'PROVIDER', 'ADMIN']
                      .map((role) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_roleLabel(role)),
                              selected: state.roleFilter == role,
                              onSelected: (_) => ref
                                  .read(adminUsersProvider.notifier)
                                  .setRoleFilter(role),
                              selectedColor:
                                  AppColors.primary.withOpacity(0.2),
                              checkmarkColor: AppColors.primary,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : state.error != null
              ? EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error al cargar',
                  subtitle: state.error,
                  actionLabel: 'Reintentar',
                  onAction: () =>
                      ref.read(adminUsersProvider.notifier).refresh(),
                )
              : state.filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'Sin resultados',
                      subtitle:
                          'No se encontraron usuarios con ese filtro.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          ref.read(adminUsersProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _UserCard(user: state.filtered[i]),
                      ),
                    ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'ALL' => 'Todos',
        'CLIENT' => 'Clientes',
        'PROVIDER' => 'Jornaleras',
        'ADMIN' => 'Admin',
        _ => role,
      };
}

// ── User Card ─────────────────────────────────────────────────

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});
  final UserAdminModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = switch (user.role) {
      'PROVIDER' => AppColors.primary,
      'ADMIN' => AppColors.error,
      _ => AppColors.secondary,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isActive
              ? AppColors.outlineVariant
              : AppColors.error.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: user.isActive
              ? roleColor.withOpacity(0.2)
              : AppColors.error.withOpacity(0.15),
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: user.isActive ? roleColor : AppColors.error,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: TextStyle(
                  color: user.isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  decoration:
                      user.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _roleLabel(user.role),
                style:
                    TextStyle(color: roleColor, fontSize: 10),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12)),
            if (!user.isActive)
              const Text('BANEADO',
                  style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: user.role != 'ADMIN'
            ? PopupMenuButton<String>(
                color: AppColors.surface,
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.onSurfaceVariant),
                onSelected: (v) {
                  if (v == 'toggle') {
                    ref.read(adminUsersProvider.notifier).toggleBan(
                          user.id,
                          currentlyActive: user.isActive,
                        );
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(children: [
                      Icon(
                        user.isActive
                            ? Icons.block_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 18,
                        color: user.isActive
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isActive ? 'Banear usuario' : 'Desbanear',
                        style: TextStyle(
                          color: user.isActive
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ]),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'CLIENT' => 'Cliente',
        'PROVIDER' => 'Jornalera',
        'ADMIN' => 'Admin',
        _ => role,
      };
}
