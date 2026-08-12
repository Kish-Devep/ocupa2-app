import 'package:flutter/material.dart';

/// Paleta exacta del sistema de diseño entregado (Material Design 3,
/// "Corporate Modern" con ancla Deep Teal y CTA ámbar/naranja).
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF00464A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF006064);
  static const Color onPrimaryContainer = Color(0xFF8FD8DC);

  static const Color secondary = Color(0xFF006972);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF8FEEFC);
  static const Color onSecondaryContainer = Color(0xFF006D77);

  static const Color tertiary = Color(0xFF613300);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF834700);
  static const Color onTertiaryContainer = Color(0xFFFFBF89);
  static const Color tertiaryFixed = Color(0xFFFFDCC2);

  /// CTA cálido: "Aplicar", "Pagar y publicar". Nunca para navegación.
  static const Color cta = Color(0xFFF57C00);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF3F4949);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);

  static const Color outline = Color(0xFF6F7979);
  static const Color outlineVariant = Color(0xFFBEC8C9);

  // Semántica de estados de aplicación (documentada en el design system).
  static const Color statusReviewBg = Color(0xFFFFF3E0);
  static const Color statusReviewFg = Color(0xFFE65100);
  static const Color statusDiscardedBg = Color(0xFFE1E3E4);
  static const Color statusDiscardedFg = Color(0xFF3F4949);
  static const Color statusFinalistBg = Color(0xFFE3F2FD);
  static const Color statusFinalistFg = Color(0xFF0D47A1);
  static const Color statusWinnerBg = Color(0xFFE8F5E9);
  static const Color statusWinnerFg = Color(0xFF1B5E20);
}
