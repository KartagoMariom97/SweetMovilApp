import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper sobre SharedPreferences para configuraciones no sensibles.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyLocale = 'locale';

  bool get onboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen() => _prefs.setBool(_keyOnboardingSeen, true);

  String get locale => _prefs.getString(_keyLocale) ?? 'es';
  Future<void> setLocale(String locale) => _prefs.setString(_keyLocale, locale);
}
