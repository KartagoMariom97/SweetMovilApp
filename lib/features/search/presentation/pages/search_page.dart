import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 12: Búsqueda con chips de categorías
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(child: Text('Search — Fase 12')),
    );
  }
}
