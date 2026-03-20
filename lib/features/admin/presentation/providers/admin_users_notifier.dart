import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/features/admin/data/models/user_admin_model.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_dashboard_notifier.dart';

// ── State ────────────────────────────────────────────────────

class AdminUsersState {
  const AdminUsersState({
    this.users = const [],
    this.filtered = const [],
    this.roleFilter = 'ALL',
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<UserAdminModel> users;
  final List<UserAdminModel> filtered;
  final String roleFilter; // ALL | CLIENT | PROVIDER | ADMIN
  final String searchQuery;
  final bool isLoading;
  final String? error;

  AdminUsersState copyWith({
    List<UserAdminModel>? users,
    List<UserAdminModel>? filtered,
    String? roleFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      AdminUsersState(
        users: users ?? this.users,
        filtered: filtered ?? this.filtered,
        roleFilter: roleFilter ?? this.roleFilter,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Provider ─────────────────────────────────────────────────

final adminUsersProvider =
    NotifierProvider<AdminUsersNotifier, AdminUsersState>(
  AdminUsersNotifier.new,
);

class AdminUsersNotifier extends Notifier<AdminUsersState> {
  @override
  AdminUsersState build() {
    Future.microtask(_load);
    return const AdminUsersState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final users = await ref.read(adminDsProvider).getUsers();
      state = state.copyWith(
        users: users,
        filtered: _applyFilters(users, state.roleFilter, state.searchQuery),
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _load();
  }

  void setRoleFilter(String role) {
    state = state.copyWith(
      roleFilter: role,
      filtered: _applyFilters(state.users, role, state.searchQuery),
    );
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filtered: _applyFilters(state.users, state.roleFilter, query),
    );
  }

  Future<void> toggleBan(String userId, {required bool currentlyActive}) async {
    try {
      await ref.read(adminDsProvider).toggleUserActive(
            userId,
            isActive: !currentlyActive,
          );
      final updated = state.users.map((u) {
        if (u.id == userId) {
          return UserAdminModel(
            id: u.id,
            email: u.email,
            role: u.role,
            isActive: !currentlyActive,
            createdAt: u.createdAt,
            firstName: u.firstName,
            lastName: u.lastName,
            phone: u.phone,
            isAvailable: u.isAvailable,
          );
        }
        return u;
      }).toList();

      state = state.copyWith(
        users: updated,
        filtered: _applyFilters(updated, state.roleFilter, state.searchQuery),
      );
      ref.invalidate(adminDashboardProvider);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<UserAdminModel> _applyFilters(
    List<UserAdminModel> users,
    String role,
    String query,
  ) {
    return users.where((u) {
      final matchesRole = role == 'ALL' || u.role == role;
      final matchesQuery = query.isEmpty ||
          u.email.toLowerCase().contains(query.toLowerCase()) ||
          (u.displayName.toLowerCase().contains(query.toLowerCase()));
      return matchesRole && matchesQuery;
    }).toList();
  }
}
