import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_mobile_app/app.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI overlay oscura (status bar blanca sobre fondo oscuro)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar SharedPreferences antes de crear el árbol de widgets
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorageService(prefs)),
      ],
      child: const SweetApp(),
    ),
  );
}
