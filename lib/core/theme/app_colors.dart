import 'package:flutter/material.dart';

/// Design tokens de Sweet — Dark theme
abstract final class AppColors {
  // ── Primarios ─────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);      // Violeta Sweet
  static const Color primaryVariant = Color(0xFF5B21B6);
  static const Color secondary = Color(0xFF4A9EED);    // Azul acción
  static const Color secondaryVariant = Color(0xFF2563EB);

  // ── Semánticos ────────────────────────────────────────────
  static const Color success = Color(0xFF15803D);      // Verde confirmado
  static const Color successContainer = Color(0xFF1A4D2E);
  static const Color warning = Color(0xFFF59E0B);      // Amber pendiente
  static const Color warningContainer = Color(0xFF5C3D1A);
  static const Color error = Color(0xFFEF4444);        // Rojo error
  static const Color errorContainer = Color(0xFF5C1A1A);
  static const Color info = Color(0xFF4A9EED);

  // ── Fondos ────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D1A);   // Fondo app
  static const Color surface = Color(0xFF1A1A2E);      // Fondo pantalla
  static const Color surfaceVariant = Color(0xFF252540);
  static const Color surfaceContainer = Color(0xFF1E1E3A);

  // ── Texto ─────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFE5E5E5);       // Texto primario
  static const Color onSurfaceVariant = Color(0xFFA0A0A0); // Texto secundario
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFE5E5E5);

  // ── Bordes ────────────────────────────────────────────────
  static const Color outline = Color(0xFF3A3A5C);
  static const Color outlineVariant = Color(0xFF2A2A45);

  // ── Estados booking ───────────────────────────────────────
  static const Color bookingPending = Color(0xFFF59E0B);
  static const Color bookingConfirmed = Color(0xFF4A9EED);
  static const Color bookingInProgress = Color(0xFF7C3AED);
  static const Color bookingCompleted = Color(0xFF15803D);
  static const Color bookingCancelled = Color(0xFF6B7280);
  static const Color bookingDisputed = Color(0xFFEF4444);
}
