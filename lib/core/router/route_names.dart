/// Nombres y paths de todas las rutas de la app.
abstract final class RouteNames {
  // Auth
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';

  // Shell (tabs) — Cliente
  static const String home = 'home';
  static const String search = 'search';
  static const String bookings = 'bookings';
  static const String notifications = 'notifications';
  static const String profile = 'profile';

  // Cliente — sub-rutas
  static const String providerProfile = 'provider-profile';
  static const String bookingNew = 'booking-new';
  static const String bookingDetail = 'booking-detail';
  static const String chat = 'chat';

  // Proveedor
  static const String providerDashboard = 'provider-dashboard';
  static const String providerServices = 'provider-services';
  static const String providerRequests = 'provider-requests';
  static const String providerChatList = 'provider-chat-list';
  static const String providerProfileEdit = 'provider-profile-edit';

  // Admin
  static const String admin = 'admin';
  static const String adminUsers = 'admin-users';
  static const String adminBookings = 'admin-bookings';
  static const String adminReports = 'admin-reports';
  static const String adminProfile = 'admin-profile';
}

abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Shell — Cliente
  static const String home = '/home';
  static const String search = '/search';
  static const String bookings = '/bookings';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Sub-rutas
  static const String providerProfile = '/provider/:id';
  static const String bookingNew = '/booking/new';
  static const String bookingDetail = '/booking/:id';
  static const String chat = '/chat/:id';

  // Proveedor
  static const String providerDashboard = '/provider-home';
  static const String providerServices = '/provider-home/services';
  static const String providerRequests = '/provider-home/requests';
  static const String providerChatList = '/provider-home/chats';
  static const String providerProfileEdit = '/provider-home/profile';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminBookings = '/admin/bookings';
  static const String adminReports = '/admin/reports';
  static const String adminProfile = '/admin/profile';
}
