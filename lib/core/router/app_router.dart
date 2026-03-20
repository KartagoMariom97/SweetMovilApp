import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/auth/presentation/pages/splash_page.dart';
import 'package:sweet_mobile_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:sweet_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:sweet_mobile_app/features/auth/presentation/pages/register_page.dart';
import 'package:sweet_mobile_app/features/home/presentation/pages/home_page.dart';
import 'package:sweet_mobile_app/features/search/presentation/pages/search_page.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:sweet_mobile_app/features/bookings/presentation/pages/booking_detail_page.dart';
import 'package:sweet_mobile_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sweet_mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:sweet_mobile_app/features/provider_profile/presentation/pages/provider_profile_page.dart';
import 'package:sweet_mobile_app/features/chat/presentation/pages/chat_page.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/pages/provider_dashboard_page.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/pages/provider_services_page.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/pages/provider_requests_page.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/pages/provider_chat_list_page.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/pages/provider_profile_edit_page.dart';
import 'package:sweet_mobile_app/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sweet_mobile_app/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:sweet_mobile_app/features/admin/presentation/pages/admin_users_page.dart';
import 'package:sweet_mobile_app/features/admin/presentation/pages/admin_bookings_page.dart';
import 'package:sweet_mobile_app/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:sweet_mobile_app/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:sweet_mobile_app/shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final role = authState.role;
      final location = state.matchedLocation;

      final isAuthRoute = location == RoutePaths.login ||
          location == RoutePaths.register ||
          location == RoutePaths.onboarding;
      final isSplash = location == RoutePaths.splash;

      if (isSplash) return null; // Splash maneja su propia lógica

      if (!isLoggedIn && !isAuthRoute) return RoutePaths.login;
      if (isLoggedIn && isAuthRoute) {
        return switch (role) {
          'ADMIN' => RoutePaths.admin,
          'PROVIDER' => RoutePaths.providerDashboard,
          _ => RoutePaths.home,
        };
      }

      // Aislamiento de zonas por rol
      if (isLoggedIn) {
        // Admin bloqueado de zonas cliente/proveedor
        if (role == 'ADMIN' && !location.startsWith('/admin')) {
          return RoutePaths.admin;
        }
        // Proveedor bloqueado de zona cliente y admin
        if (role == 'PROVIDER' && location.startsWith('/home')) {
          return RoutePaths.providerDashboard;
        }
        if (role == 'PROVIDER' && location.startsWith('/admin')) {
          return RoutePaths.providerDashboard;
        }
        // Cliente bloqueado de zona proveedor y admin
        if (role == 'CLIENT' && location.startsWith('/provider-home')) {
          return RoutePaths.home;
        }
        if (role == 'CLIENT' && location.startsWith('/admin')) {
          return RoutePaths.home;
        }
      }

      return null;
    },
    routes: [
      // ── Auth ─────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),

      // ── Shell Cliente ─────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child, role: 'CLIENT'),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: RoutePaths.search,
            name: RouteNames.search,
            builder: (_, __) => const SearchPage(),
          ),
          GoRoute(
            path: RoutePaths.bookings,
            name: RouteNames.bookings,
            builder: (_, __) => const BookingsPage(),
          ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),

      // ── Shell Proveedor ───────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child, role: 'PROVIDER'),
        routes: [
          GoRoute(
            path: RoutePaths.providerDashboard,
            name: RouteNames.providerDashboard,
            builder: (_, __) => const ProviderDashboardPage(),
          ),
          GoRoute(
            path: RoutePaths.providerServices,
            name: RouteNames.providerServices,
            builder: (_, __) => const ProviderServicesPage(),
          ),
          GoRoute(
            path: RoutePaths.providerRequests,
            name: RouteNames.providerRequests,
            builder: (_, __) => const ProviderRequestsPage(),
          ),
          GoRoute(
            path: RoutePaths.providerChatList,
            name: RouteNames.providerChatList,
            builder: (_, __) => const ProviderChatListPage(),
          ),
          GoRoute(
            path: RoutePaths.providerProfileEdit,
            name: RouteNames.providerProfileEdit,
            builder: (_, __) => const ProviderProfileEditPage(),
          ),
        ],
      ),

      // ── Shell Admin ───────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.admin,
            name: RouteNames.admin,
            builder: (_, __) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: RoutePaths.adminUsers,
            name: RouteNames.adminUsers,
            builder: (_, __) => const AdminUsersPage(),
          ),
          GoRoute(
            path: RoutePaths.adminBookings,
            name: RouteNames.adminBookings,
            builder: (_, __) => const AdminBookingsPage(),
          ),
          GoRoute(
            path: RoutePaths.adminReports,
            name: RouteNames.adminReports,
            builder: (_, __) => const AdminReportsPage(),
          ),
          GoRoute(
            path: RoutePaths.adminProfile,
            name: RouteNames.adminProfile,
            builder: (_, __) => const AdminProfilePage(),
          ),
        ],
      ),

      // ── Rutas globales (fuera del shell) ──────────────────
      GoRoute(
        path: RoutePaths.providerProfile,
        name: RouteNames.providerProfile,
        builder: (_, state) => ProviderProfilePage(
          providerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.chat,
        name: RouteNames.chat,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          // Si id == 'new', pasamos los query params al notifier
          if (id == 'new') {
            final providerId = state.uri.queryParameters['providerId'] ?? '';
            final bookingId = state.uri.queryParameters['bookingId'];
            final arg = 'new?providerId=$providerId'
                '${bookingId != null ? '&bookingId=$bookingId' : ''}';
            return ChatPage(conversationId: arg);
          }
          return ChatPage(conversationId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.bookingDetail,
        name: RouteNames.bookingDetail,
        builder: (_, state) => BookingDetailPage(
          bookingId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
