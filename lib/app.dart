import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/router/app_router.dart';
import 'package:sweet_mobile_app/core/theme/app_theme.dart';

class SweetApp extends ConsumerWidget {
  const SweetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Sweet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
