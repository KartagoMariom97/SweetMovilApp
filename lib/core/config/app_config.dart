/// Configuración central de la app.
/// Cambiar [_env] según el ambiente de compilación.
enum AppEnvironment { development, staging, production }

class AppConfig {
  AppConfig._();

  // Cambiar via --dart-define=ENV=production al compilar
  static const _envStr =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static AppEnvironment get env {
    switch (_envStr) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }

  static String get baseUrl {
    switch (env) {
      case AppEnvironment.production:
        return 'https://api.sweetapp.com/api/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.sweetapp.com/api/v1';
      case AppEnvironment.development:
        return 'http://10.0.2.2:3000/api/v1'; // Emulador Android → localhost
    }
  }

  static String get wsUrl {
    switch (env) {
      case AppEnvironment.production:
        return 'wss://api.sweetapp.com';
      case AppEnvironment.staging:
        return 'wss://staging-api.sweetapp.com';
      case AppEnvironment.development:
        return 'ws://10.0.2.2:3000';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const bool logRequests = true;
}
